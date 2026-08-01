#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

# NOTE: this runs outside the chroot!


from __future__ import annotations

import os
import platform
import re
import subprocess
import time
import traceback
from dataclasses import dataclass, field
from pathlib import Path

import libcalamares
from libcalamares.utils import host_env_process_output
import gettext
_ = gettext.translation(
    "calamares-python", localedir=libcalamares.utils.gettext_path(),
    languages=libcalamares.utils.gettext_languages(), fallback=True,
).gettext

status: str = ""

# Copying the image is the only step that takes long enough to be worth
# reporting progress inside of, so it gets a range rather than a fixed value.
IMAGE_COPY_START = 0.10
IMAGE_COPY_END = 0.85


def pretty_status_message() -> str:
    return status


def _report(fraction: float, message: str) -> None:
    global status
    status = message
    libcalamares.job.setprogress(fraction)


STATE_DIR = Path("/run/kde-linux-install")


def _image_version() -> str:
    # IMAGE_VERSION comes from os-release, not the environment.
    env = os.environ.get("IMAGE_VERSION", "")
    if env:
        return env

    try:
        version = platform.freedesktop_os_release().get("IMAGE_VERSION", "")
        if version:
            return version
    except (OSError, AttributeError):
        pass

    for candidate in (Path("/etc/os-release"), Path("/usr/lib/os-release")):
        try:
            content = candidate.read_text()
        except OSError:
            continue
        for line in content.splitlines():
            key, sep, value = line.partition("=")
            if sep and key.strip() == "IMAGE_VERSION":
                return value.strip().strip('"').strip("'")

    return ""


@dataclass
class InstallState:
    root: Path
    tmpdir: Path
    device: str
    blockdev: str
    partnum: str | None
    espdev: str | None = None
    image_version: str = field(default_factory=_image_version)


def run() -> tuple[str, str] | None:
    root_dir = libcalamares.globalstorage.value("rootMountPoint")
    if not root_dir:
        return ("subvol", _("No target root (rootMountPoint) was provided."))

    root = Path(root_dir)
    STATE_DIR.mkdir(parents=True, exist_ok=True)

    try:
        state = _resolve_state(root)
        _correct_partition_type(state)
        _teardown_existing(state)
        _create_subvolumes(state)
        _copy_image(state)
        _build_mount_stack(state)
        _populate_base_filesystem(state)
        _apply_factory_and_sysusers(state)
        _apply_presets_and_tmpfiles(state)
    except _StageError as err:
        libcalamares.utils.error(str(err))
        return ("subvol", str(err))
    except Exception as err:
        libcalamares.utils.error(traceback.format_exc())
        return ("subvol", _("Unexpected error: {}").format(err))

    _report(1.0, _("System image installed."))
    return None


class _StageError(RuntimeError):
    pass


def _run(cmd: list[str], **kwargs) -> str:
    """basically `set -ex`"""
    check = kwargs.pop("check", True)
    kwargs.setdefault("text", True)
    libcalamares.utils.debug("running: {}".format(" ".join(cmd)))
    try:
        result = subprocess.run(cmd, capture_output=True, check=check, **kwargs)
    except subprocess.CalledProcessError as err:
        stderr = (err.stderr or "").strip()
        raise _StageError(
            _("Command failed ({code}): {cmd}\n{stderr}").format(
                code=err.returncode, cmd=" ".join(cmd), stderr=stderr
            )
        ) from err
    except FileNotFoundError as err:
        raise _StageError(_("Command not found: {}").format(cmd[0])) from err
    return (result.stdout or "").strip()


def _empty_directory(directory: Path) -> None:
    """Unmount and remove everything inside directory (but not the directory itself)."""
    entries = sorted(entry.name for entry in directory.iterdir())
    if not entries:
        return
    _run(["umount", "-R", *entries], cwd=directory, check=False)
    _run(["rm", "-rf", "--", *entries], cwd=directory)


def _resolve_state(root: Path) -> InstallState:
    _report(0.0, _("Preparing installation…"))

    device = _run(["findmnt", "--noheadings", "--nofsroot", "--output", "SOURCE", str(root)])
    if not device:
        raise _StageError(_("Could not determine the source device for {}.").format(root))

    blockdev, partnum = _resolve_blockdev_and_partnum(device)

    tmpdir = STATE_DIR / "subvol-tmp"
    tmpdir.mkdir(parents=True, exist_ok=True)

    state = InstallState(root=root, tmpdir=tmpdir, device=device, blockdev=blockdev, partnum=partnum)

    # Before teardown wipes the target.
    if not state.image_version:
        raise _StageError(_("Could not determine IMAGE_VERSION from os-release."))
    libcalamares.utils.debug(f"image version: {state.image_version}")

    return state


def _resolve_blockdev_and_partnum(device: str) -> tuple[str, str | None]:
    # Correct the GPT partition type if necessary (e.g., from manual partitioning)
    # This ensures /dev/gpt-auto-root is available for systemd detection
    realdevice = _run(["realpath", "--relative-to", "/dev", device])

    dm_dir = Path(f"/sys/block/{realdevice}/dm")
    if dm_dir.is_dir():
        slaves_dir = Path(f"/sys/block/{realdevice}/slaves")
        for slave in sorted(slaves_dir.iterdir()):
            realdevice = slave.name
            break

    parent_link = Path(f"/sys/class/block/{realdevice}/..")
    resolved = _run(["readlink", "--canonicalize", str(parent_link)])
    blockdev = f"/dev/{Path(resolved).name}"

    # Extract partition number from device path
    match = re.search(r"[^0-9](\d+)$", device)
    partnum = match.group(1) if match else None

    return blockdev, partnum


def _correct_partition_type(state: InstallState) -> None:
    _report(0.02, _("Checking partition type…"))

    root_guids = {
        "x86_64": "4f68bce3-e8cd-4db1-96e7-fbcaf984b709",
        "i686": "44479540-f297-41b2-9af7-d131d5f0458a",
        "i386": "44479540-f297-41b2-9af7-d131d5f0458a",
        "aarch64": "b921b045-1df0-41c3-af44-4c6f280d3fae",
        "armv7l": "69dad710-2ce4-4e3c-b16c-21a1d49abed3",
        "armv7h": "69dad710-2ce4-4e3c-b16c-21a1d49abed3",
        "riscv64": "72ec70a6-cf74-40e6-bd49-4bda08e8f224",
        "loongarch64": "77055800-792c-4f94-b39a-98c91b762bb6",
    }
    arch = _run(["uname", "-m"])
    root_guid = root_guids.get(arch, "")
    if not root_guid:
        # Unknown architecture: $arch, skipping partition type correction
        libcalamares.utils.debug(f"unknown architecture {arch}, not correcting the partition type")
        return

    if not state.partnum:
        return

    # Check current partition type and correct if needed
    current_guid = _run(
        ["sfdisk", "--part-type", state.blockdev, state.partnum], check=False
    ).lower()

    if current_guid and current_guid != root_guid:
        # Correcting partition type to the architecture's Linux root type
        _run(["sfdisk", "--part-type", state.blockdev, state.partnum, root_guid], check=False)
        # Reload partition table
        _run(["partprobe", state.blockdev], check=False)
        # Give udev a moment to update /dev/gpt-auto-root
        _run(["udevadm", "settle"], check=False)
        time.sleep(1)


def _teardown_existing(state: InstallState) -> None:
    _report(0.05, _("Clearing existing mount…"))

    root = str(state.root)

    # Calamares likes to mount stuff even with an empty config. Throw it away again.
    _empty_directory(state.root)
    _run(["btrfs", "subvolume", "sync", root], check=False)
    # unmount is important as otherwise we still hold a subvolume open and it can never sync deletion
    _run(["umount", "-R", "--lazy", root], check=False)


def _create_subvolumes(state: InstallState) -> None:
    _report(0.08, _("Creating subvolumes…"))

    Path("/system").mkdir(exist_ok=True)
    if not os.path.ismount("/system"):
        _run(["mount", "-o", "ro", "/dev/gpt-auto-root", "/system"])
    _run(["mount", "-o", "rw", state.device, str(state.tmpdir)])

    tmp = str(state.tmpdir)
    _empty_directory(state.tmpdir)
    _run(["btrfs", "subvolume", "sync", tmp], check=False)

    _run(["btrfs", "quota", "enable", "--simple", tmp])
    _run(["btrfs", "subvolume", "create", f"{tmp}/@system"])
    _run(["btrfs", "subvolume", "create", f"{tmp}/@system/etc"])
    for sub in ("boot", "proc", "sys", "dev", "run", "usr"):
        (state.tmpdir / "@system" / sub).mkdir(parents=True, exist_ok=True)


def _copy_image(state: InstallState) -> None:
    src = "/dev/gpt-auto-root"
    dst = state.tmpdir / f"kde-linux_{state.image_version}.erofs"

    _report(IMAGE_COPY_START, _("Copying system image…"))

    fd = os.open(src, os.O_RDONLY)
    try:
        total = os.lseek(fd, 0, os.SEEK_END)  # st_size is 0 for block devices
        os.lseek(fd, 0, os.SEEK_SET)
        if total <= 0:
            raise _StageError(_("Could not determine the size of {}.").format(src))

        done = 0
        chunk_size = 16 << 20  # 16 MiB
        with open(dst, "wb") as out:
            while True:
                chunk = os.read(fd, chunk_size)
                if not chunk:
                    break
                out.write(chunk)
                done += len(chunk)
                fraction = IMAGE_COPY_START + (IMAGE_COPY_END - IMAGE_COPY_START) * (done / total)
                _report(
                    fraction,
                    _("Copying system image ({}/{} MiB)").format(done >> 20, total >> 20),
                )
            out.flush()
            os.fsync(out.fileno())
    finally:
        os.close(fd)


def _build_mount_stack(state: InstallState) -> None:
    _report(IMAGE_COPY_END, _("Assembling mount stack…"))

    root = state.root

    # Overmount calamares' mount with the subvol mount
    _run(["mount", "-o", "subvol=@system", state.device, str(root)])
    _run(["mount", "-t", "proc", "proc", str(root / "proc")])
    _run(["mount", "-t", "sysfs", "sys", str(root / "sys")])
    _run(["mount", "-o", "bind", "/dev", str(root / "dev")])
    _run(["mount", "-t", "tmpfs", "tmpfs", str(root / "run")])
    # This is not part of @system but rather the $ROOT (do not move this to the mkdir list of @system!)
    (root / "run" / "udev").mkdir(parents=True, exist_ok=True)
    _run(["mount", "-o", "bind", "/run/udev", str(root / "run" / "udev")])
    efivars = root / "sys" / "firmware" / "efi" / "efivars"
    if efivars.is_dir():
        _run(["mount", "-t", "efivarfs", "efivarfs", str(efivars)], check=False)
    _run(["mount", "-o", "ro,X-mount.subdir=usr", "/dev/gpt-auto-root", str(root / "usr")])

    # ESP is a bit tricky. We ask systemd for an ESP on the block device of the
    # root partition (which we already resolved, luks devices and all).
    espdev = _run(["/usr/lib/find-esp", state.blockdev])
    if not espdev:
        raise _StageError(
            _("Could not locate an EFI system partition on {}.").format(state.blockdev)
        )
    state.espdev = espdev
    _run(["mount", espdev, str(root / "boot")])


def _populate_base_filesystem(state: InstallState) -> None:
    _report(0.90, _("Populating base filesystem…"))

    # Bit of a crutch to get systemd's base_filesystem_create() to run so the
    # / gets populated with symlinks. Exit code is not indicative of to the
    # function having run - ignore it.
    _run(["systemd-nspawn", "-D", str(state.root), "true"], check=False)


def _apply_factory_and_sysusers(state: InstallState) -> None:
    root = str(state.root)

    _report(0.92, _("Applying factory configuration…"))
    # Apply the factory
    host_env_process_output(
        ["/usr/lib/etc-factory", "--sysroot", f"{root}/", "--replace", "--migrate"],
        None,
    )

    _report(0.95, _("Initializing users…"))
    # Initialize systemd stuff
    _run(["systemd-sysusers", f"--root={root}"])

    # Add a marker file to indicate this install included plasma-setup.
    # This ensures plasma-setup won't run for existing installations.
    marker_dir = state.root / "var" / "lib" / "kde-linux"
    marker_dir.mkdir(parents=True, mode=0o755, exist_ok=True)
    marker = marker_dir / "installed-with-plasma-setup"
    marker.touch(mode=0o644, exist_ok=True)


def _apply_presets_and_tmpfiles(state: InstallState) -> None:
    root = str(state.root)

    _report(0.97, _("Applying service presets…"))
    # Make sure presets are applied
    _run(["systemctl", f"--root={root}", "preset-all"])
    _run(["systemctl", f"--root={root}", "preset-all", "--global"])

    _report(0.99, _("Creating tmpfiles…"))
    # tmpfiles are final and should come at last
    # exclude /usr because some tmpfiles are rubbish and assume /usr is writable...
    _run(
        [
            "systemd-tmpfiles",
            f"--root={root}",
            "--exclude-prefix=/usr",
            "--create",
        ],
        check=False,
    )
