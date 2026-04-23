#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2023 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

# Build image using mkosi, well, somewhat. mkosi is actually a bit too inflexible for our purposes so we generate a OS
# tree using mkosi and then construct shipable .iso9660 (and gpt raw disk images) for installation and tarballs (for systemd-sysupdate)
# ourselves.

set -ex

# TODO: REMOVE WHEN SYSTEMD STABLE GETS ISO9660 SUPPORT
#------------------------------------------------------------------------------------------------------------------------------------
# --- Configuration ---
BUILDER_USER="aurbuilder"
AUR_PACKAGE="systemd-git"
WORK_DIR="/tmp/aur_build"

# 1. Install build dependencies
pacman -Syu --noconfirm --needed base-devel git sudo

# 2. Create temporary builder user with sudo (NOPASSWD)
if id "$BUILDER_USER" &>/dev/null; then
    userdel -r -f "$BUILDER_USER" 2>/dev/null || true
fi
useradd -m -G wheel "$BUILDER_USER"
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-builder
chmod 440 /etc/sudoers.d/99-builder

# 3. Prepare work directory
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
chown "$BUILDER_USER:$BUILDER_USER" "$WORK_DIR"

# 4. Build packages (but do NOT install yet)
su - "$BUILDER_USER" <<EOF
set -euo pipefail
cd "$WORK_DIR"
git clone https://aur.archlinux.org/${AUR_PACKAGE}.git
cd ${AUR_PACKAGE}
makepkg -s --noconfirm --nocheck --rmdeps   # only build, no -i
EOF

# 5. Brutally remove existing stable systemd packages (ignore dependencies)
echo ":: Removing old systemd packages (force)..."
pacman -Rdd --noconfirm systemd systemd-libs systemd-sysvcompat systemd-ukify systemd-tests 2>/dev/null || true

echo ":: Removing existing stable systemd packages..."
stable_packages=$(pacman -Q | grep '^systemd' | grep -v '\-git' | grep -v 'systemd-bootchart' | cut -d' ' -f1 || true)
if [ -n "$stable_packages" ]; then
    pacman -Rdd --noconfirm $stable_packages
fi

# 6. Install the newly built packages
echo ":: Installing systemd-git packages..."
pacman -U --noconfirm "$WORK_DIR"/systemd-git/*.pkg.tar.zst

# 7. Cleanup
userdel -r -f "$BUILDER_USER" 2>/dev/null || true
rm -f /etc/sudoers.d/99-builder
rm -rf "$WORK_DIR"

echo ":: systemd-git installation completed successfully."
systemd-repart --version
systemd-repart --help | grep --color=always el-torito || echo "WARNING: --el-torito option not found!"

cat /usr/lib/udev/rules.d/99-systemd.rules
#---------------------------------------------------------------------------------------------------------------------------------

# Creates an archive containing the data from just the kde-linux-debug repository packages,
# essentially the debug symbols for KDE apps, to be used as a sysext.
make_debug_archive () {
  # Create an empty directory at /var/tmp/debugroot to install the packages to before compressing.
  rm --recursive --force /var/tmp/debugroot
  mkdir --parents /var/tmp/debugroot

  # Install all packages in the kde-linux-debug repository to /var/tmp/debugroot.
  pacstrap -c /var/tmp/debugroot $(pacman --sync --list --quiet kde-linux-debug)

  # systemd-sysext uses the os-release in extension-release.d to verify the sysext matches the base OS,
  # and can therefore be safely installed. Copy the base OS' os-release there.
  mkdir --parents /var/tmp/debugroot/usr/lib/extension-release.d/
  cp "${OUTPUT}/usr/lib/os-release" /var/tmp/debugroot/usr/lib/extension-release.d/extension-release.debug

  # Finally compress /var/tmp/debugroot/usr into a zstd tarball at $DEBUG_TAR.
  # We actually only need usr because that's where all the relevant stuff lays anyways.
  # TODO: needs really moving to erofs instead of tar
  tar --directory=/var/tmp/debugroot --create --file="$DEBUG_TAR" usr
  zstd --threads=0 --rm "$DEBUG_TAR" # --threads=0 automatically uses the optimal number
  rm --recursive --force /var/tmp/debugroot
}

EPOCH=$(date --utc +%s) # The epoch (only used to then construct the various date strings)
VERSION_DATE=$(date --utc --date="@$EPOCH" --rfc-3339=seconds)
VERSION=$(date --utc --date="@$EPOCH" +%Y%m%d%H%M)
OUTPUT="mkosi.output/kde-linux_$VERSION"   # Built rootfs path (mkosi uses this directory by default)

# Canonicalize the path in $OUTPUT to avoid any possible path issues.
OUTPUT="$(readlink --canonicalize-missing "$OUTPUT")"

MAIN_UKI=${OUTPUT}.efi               # Output main UKI path
LIVE_UKI=${OUTPUT}_live.efi          # Output live UKI path
DEBUG_TAR=${OUTPUT}_debug-x86-64.tar # Output debug archive path (.zst will be added)
# SUPER WARNING: Do not use the more common foo.erofs.caibx suffix. It breaks stuff!
# https://github.com/systemd/systemd/issues/38605
# We'll rename things accordingly via sysupdate.d files.
ROOTFS_CAIBX=${OUTPUT}_root-x86-64.caibx
ROOTFS_EROFS=${OUTPUT}_root-x86-64.erofs # Output erofs image path
ISO="${OUTPUT}.iso" # both a valid GPT disk image and a bootable ISO

EFI_BASE=kde-linux_${VERSION} # Base name of the UKI in the image's ESP (exported so it can be used in basic-test-efi-addon.sh)
EFI=${EFI_BASE}+3.efi      # Name of primary UKI in the image's ESP (with tries counter for installed system)
LIVE_EFI=${EFI_BASE}.efi   # Name of live UKI in the ESP (no tries counter — ESP is read-only on ISO)

# Clean up old build artifacts.
rm --recursive --force kde-linux.cache/*.raw kde-linux.cache/*.iso kde-linux.cache/*.mnt

# FIXME: temporary hack to work around repo priorities being off in the CI image
cat <<- EOF > mkosi.sandbox/etc/pacman.conf
[kde-linux]
# Signature checking is not needed because the packages are served over HTTPS and we have no mirrors
SigLevel = Never
Server = https://storage.kde.org/kde-linux-packages/testing/repo/packages/

[kde-linux-debug]
SigLevel = Never
Server = https://storage.kde.org/kde-linux-packages/testing/repo/packages-debug/
EOF

# Ignore the regular Linux Kernel so it doesnt get pulled in accidently
sed 's/#IgnorePkg   =/IgnorePkg = linux linux-headers/' /etc/pacman.conf.nolinux >> mkosi.sandbox/etc/pacman.conf

# Enable multilib; we need it later for steam-devices
cat <<EOF >> mkosi.sandbox/etc/pacman.conf
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

mkdir --parents mkosi.sandbox/etc/pacman.d
# Ensure the packages repo and the base image do not go out of sync
# by using the same snapshot date from BUILD_REPO.txt for both
# WARNING: code copy in bootstrap.sh
BUILD_REPO=$(curl --fail --silent https://storage.kde.org/kde-linux-packages/testing/repo/build_repo.txt)
if [ -z "$BUILD_REPO" ]; then
  echo "ERROR: Could not fetch build_repo.txt — refusing to build out-of-sync image." >&2
  exit 1
fi
echo "Server = ${BUILD_REPO}/\$repo/os/\$arch" > mkosi.sandbox/etc/pacman.d/mirrorlist
# ... and make sure our cache is up to date. Second --refresh forces a refresh.
pacman --sync --refresh --refresh --noconfirm

# Make sure permissions are sound
./permission-fix.sh

cargo build --release --manifest-path btrfs-migrator/Cargo.toml
cp -v btrfs-migrator/target/release/btrfs-migrator mkosi.extra/usr/lib/

rm --recursive --force kde-linux-sysupdated
git clone https://invent.kde.org/kde-linux/kde-linux-sysupdated
DESTDIR=$PWD/mkosi.extra make --directory=kde-linux-sysupdated install

rm --recursive --force etc-factory
git clone https://invent.kde.org/kde-linux/etc-factory
DESTDIR=$PWD/mkosi.extra make --directory=etc-factory install

mkosi \
    --environment="CI_COMMIT_SHORT_SHA=${CI_COMMIT_SHORT_SHA:-unknownSHA}" \
    --environment="CI_COMMIT_SHA=${CI_COMMIT_SHA:-unknownSHA}" \
    --environment="CI_PIPELINE_URL=${CI_PIPELINE_URL:-https://invent.kde.org}" \
    --environment="VERSION_DATE=${VERSION_DATE}" \
    --image-version="$VERSION" \
    "$@"

# Adjust mtime to reduce unnecessary churn between images caused by us rebuilding repos that have possible not changed in source or binary interfaces.
if [ -f "$PWD/.secure_files/ssh.key" ]; then
  # You can use `ssh-keyscan origin.files.kde.org` to get the host key
  echo "origin.files.kde.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUjdH4S7otYIdLUkOZK+owIiByjNQPzGi7GQ5HOWjO6" >> ~/.ssh/known_hosts

  chmod 600 "$PWD/.secure_files/ssh.key"

  scp -i "$PWD/.secure_files/ssh.key" kdeos@origin.files.kde.org:/home/kdeos/mtimer.json mtimer.json
  # Note: use absolute paths. since we chdir via go
  go -C ./mtimer/ run . -root "$OUTPUT" -json "$PWD/mtimer.json"
  scp -i "$PWD/.secure_files/ssh.key" mtimer.json kdeos@origin.files.kde.org:/home/kdeos/mtimer.json
fi

# NOTE: /efi must be empty so auto mounting can happen. As such we put our templates in a different directory
rm -rfv "${OUTPUT}/efi"
[ -d "${OUTPUT}/efi" ] || mkdir --mode 0700 "${OUTPUT}/efi"
[ -d "${OUTPUT}/usr/share/factory/boot" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot"
[ -d "${OUTPUT}/usr/share/factory/boot/EFI" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/EFI"
[ -d "${OUTPUT}/usr/share/factory/boot/EFI/Linux" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/EFI/Linux"
[ -d "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$EFI_BASE.efi.extra.d" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$EFI_BASE.efi.extra.d"

# Save the main UKI (with tries counter) aside as it must NOT go into factory/boot yet
# so it doesn't end up on the live ESP.
cp -v "${OUTPUT}"/kde-linux.efi "$MAIN_UKI"
rm -v "${OUTPUT}"/kde-linux.efi
mv -v "${OUTPUT}"/erofs.addon.efi "${OUTPUT}_erofs.addon.efi"
mv -v "${OUTPUT}"/live.efi "$LIVE_UKI"

make_debug_archive

# Now let's actually build the live ESP.
# We use kde-linux.cache instead of /tmp as usual because we'll probably run out of space there.

# Only LIVE_EFI (no tries counter) goes into factory/boot for the ESP.
# The installed system UKI ($EFI with +3) is added AFTER the ESP is built.
mv "$LIVE_UKI" "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$LIVE_EFI"

# Change to kde-linux.cache since we'll be working there.
cd kde-linux.cache

# Create a 280M large FAT32 filesystem inside of esp.raw.
fallocate -l 280M esp.raw
mkfs.fat -F 32 esp.raw

# Mount it to esp.raw.mnt.
mkdir -p esp.raw.mnt
mount esp.raw esp.raw.mnt

# Copy everything from /usr/share/factory/boot into esp.raw.mnt.
# At this point only LIVE_EFI is in factory/boot/EFI/Linux/ so the installed UKI (+3) is not there yet.
cp --archive --recursive "${OUTPUT}/usr/share/factory/boot/." esp.raw.mnt

# We're done, unmount esp.raw.mnt.
umount esp.raw.mnt

cd .. # and back to root

# Now add the installed system UKI (with tries counter) to factory/boot for the erofs rootfs.
# This happens AFTER the ESP build so it doesn't land on the live ESP.
cp "$MAIN_UKI" "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$EFI"

# Remove the live UKI from factory as it was only needed for the ESP build.
# The erofs rootfs should only contain the installed system UKI (+3).
rm "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$LIVE_EFI"

# Drop flatpak data from erofs. They are in the usr/share/factory and deployed from there.
rm -rf "$OUTPUT/var/lib/flatpak"
mkdir "$OUTPUT/var/lib/flatpak" # but keep a mountpoint around for the live session

time mkfs.erofs -zzstd -C 65536 --chunksize 65536 "$ROOTFS_EROFS" "$OUTPUT" > erofs.log 2>&1
cp --reflink=auto "$ROOTFS_EROFS" kde-linux.cache/root.raw

# Now assemble the image using systemd-repart and the definitions in mkosi.repart into $ISO.
# The resulting file is both a valid GPT disk image and a bootable El Torito ISO.
touch "$ISO"
systemd-repart \
    --no-pager \
    --empty=allow \
    --size=auto \
    --dry-run=no \
    --root=kde-linux.cache \
    --definitions=mkosi.repart \
    --el-torito=true \
    --el-torito-volume="KDE LINUX $VERSION" \
    --el-torito-publisher="KDE" \
    "$ISO"

# Incase the owner is root
chown -R user:user mkosi.output

# Test the ISO (which is also a valid GPT image so no need to test .raw separately)
./basic-test.py "$ISO" "$LIVE_EFI" || exit 1
rm ./mkosi.output/*.test.iso

# Create a torrent for the image
./torrent-create.rb "$VERSION" "$OUTPUT" "$ISO"

go install -v github.com/folbricht/desync/cmd/desync@latest
~/go/bin/desync make -m 32:64:128 "$ROOTFS_CAIBX" "$ROOTFS_EROFS"
# Be very careful with this file. It is here for backwards compat. It must not appear in SHA256SUMS.
# https://github.com/systemd/systemd/issues/38605
cp "$ROOTFS_CAIBX" "$ROOTFS_EROFS.caibx"

# Fake artifacts to keep older systems happy to upgrade to newer versions.
# Can be removed once we have started having revisions in our update trees.
tar -cf ${OUTPUT}_root-x86-64.tar -T /dev/null
zstd --threads=0 --rm ${OUTPUT}_root-x86-64.tar

# TODO before accepting new uploads perform sanity checks on the artifacts (e.g. the tar being well formed)

# efi images and torrents are 700, make them readable so the server can serve them
chmod go+r "$OUTPUT".* ./mkosi.output/*.efi ./mkosi.output/*.torrent
ls -lah
