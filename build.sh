#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2023 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

set -ex

# TODO: Once the Fedora packages pipeline is publishing to storage.kde.org,
# fetch and unpack the real debug.tar.zst here instead of using a placeholder.
make_debug_archive () {
  rm --recursive --force /var/tmp/debugroot
  mkdir --parents /var/tmp/debugroot/usr/lib/extension-release.d/
  cp "${OUTPUT}/usr/lib/os-release" /var/tmp/debugroot/usr/lib/extension-release.d/extension-release.debug
  tar --directory=/var/tmp/debugroot --create --file="$DEBUG_TAR" usr
  zstd --threads=0 --rm "$DEBUG_TAR"
  rm --recursive --force /var/tmp/debugroot
}

# TODO: Remove if VM Image becomes Fedora
if command -v pacman > /dev/null 2>&1; then
    echo "Arch-based VM detected, installing docker to run Fedora container"
    pacman --sync --refresh --noconfirm docker
    systemctl start docker
    docker pull fedora:rawhide
    docker run --privileged --rm \
        --volume "$PWD:/workspace" \
        --volume "/var/cache/dnf:/var/cache/dnf" \
        --volume "/dev:/dev" \
        --workdir /workspace \
        fedora:rawhide \
        sh -c "/workspace/in_docker.sh"
    exit $?
fi

EPOCH=$(date --utc +%s)
VERSION_DATE=$(date --utc --date="@$EPOCH" --rfc-3339=seconds)
VERSION=$(date --utc --date="@$EPOCH" +%Y%m%d%H%M)
OUTPUT="mkosi.output/kde-linux_$VERSION"
OUTPUT="$(readlink --canonicalize-missing "$OUTPUT")"

MAIN_UKI=${OUTPUT}.efi
LIVE_UKI=${OUTPUT}_live.efi
DEBUG_TAR=${OUTPUT}_debug-x86-64.tar
ROOTFS_CAIBX=${OUTPUT}_root-x86-64.caibx
ROOTFS_EROFS=${OUTPUT}_root-x86-64.erofs
IMG=${OUTPUT}.raw

EFI_BASE=kde-linux_${VERSION}
EFI=${EFI_BASE}+3.efi

rm --recursive --force kde-linux.cache/*.raw kde-linux.cache/*.mnt

# Pin Fedora repos to the same Koji compose used by the packages pipeline
# so the base OS and KDE packages don't go out of sync.
# TODO: Once the packages pipeline publishes compose_id.txt to storage.kde.org,
# fetch it from there instead.
COMPOSE_ID=$(curl -sf https://storage.kde.org/kde-linux-packages/testing/repo/compose_id.txt || \
             curl -sf https://kojipkgs.fedoraproject.org/compose/rawhide/latest-Fedora-Rawhide/COMPOSE_ID || true)

if [ -n "$COMPOSE_ID" ]; then
  mkdir --parents mkosi.sandbox/etc/dnf/repos.d/
  cat <<- EOF > mkosi.sandbox/etc/dnf/repos.d/fedora-pinned.repo
[fedora-pinned]
name=Fedora Rawhide (pinned to KDE Linux build compose)
baseurl=https://kojipkgs.fedoraproject.org/compose/rawhide/${COMPOSE_ID}/compose/Everything/x86_64/os/
enabled=1
gpgcheck=0
metalink=
mirrorlist=
EOF
else
  echo "WARNING: Could not fetch compose ID, using default Fedora Rawhide repos"
fi

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

# TODO: Fetch install.tar.zst from storage.kde.org once the Fedora packages
# pipeline is publishing there. For now we skip this step if it doesn't exist.
INSTALL_TAR_URL="https://storage.kde.org/kde-linux-packages/testing/repo/install.tar.zst"
if curl -sf --head "$INSTALL_TAR_URL" > /dev/null 2>&1; then
  mkdir --parents mkosi.extra
  curl -sf "$INSTALL_TAR_URL" | tar --directory=mkosi.extra --extract --zstd
else
  echo "WARNING: install.tar.zst not yet available on storage.kde.org, skipping KDE overlay"
fi

# Install all KDE build and runtime dependencies into mkosi.extra
# so they are available in the final image alongside the KDE overlay.
# These are the builddeps and rundeps from the Fedora distro-dependencies in repo-metadata.
FEDORA_DEPS_URL="https://invent.kde.org/sysadmin/repo-metadata/-/raw/master/distro-dependencies/fedora.yaml"
ALL_DEPS=$(curl -sf "$FEDORA_DEPS_URL" | python3 -c "
import sys, yaml
data = yaml.safe_load(sys.stdin)
deps = set()
for pkg in data.values():
    deps.update(pkg.get('rundeps', []))
    deps.update(pkg.get('builddeps', []))
print('\n'.join(sorted(deps)))
" | grep -v '^$' || true)

if [ -n "$ALL_DEPS" ]; then
    dnf install -y \
        --installroot="$PWD/mkosi.extra" \
        --releasever=rawhide \
        --best \
        --allowerasing \
        --skip-unavailable \
        --skip-broken \
        $ALL_DEPS || true
else
    echo "WARNING: Could not fetch or parse Fedora deps from repo-metadata"
fi

# TODO: temporary install plasma from fedora
dnf install -y \
  --installroot="$PWD/mkosi.extra" \
  --releasever=rawhide \
  --best \
  --allowerasing \
   --skip-unavailable \
    --skip-broken \
    @kde-desktop-environment

mkosi \
    --environment="CI_COMMIT_SHORT_SHA=${CI_COMMIT_SHORT_SHA:-unknownSHA}" \
    --environment="CI_COMMIT_SHA=${CI_COMMIT_SHA:-unknownSHA}" \
    --environment="CI_PIPELINE_URL=${CI_PIPELINE_URL:-https://invent.kde.org}" \
    --environment="VERSION_DATE=${VERSION_DATE}" \
    --image-version="$VERSION" \
    "$@"

if [ -f "$PWD/.secure_files/ssh.key" ]; then
  echo "origin.files.kde.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUjdH4S7otYIdLUkOZK+owIiByjNQPzGi7GQ5HOWjO6" >> ~/.ssh/known_hosts
  chmod 600 "$PWD/.secure_files/ssh.key"
  scp -i "$PWD/.secure_files/ssh.key" kdeos@origin.files.kde.org:/home/kdeos/mtimer.json mtimer.json
  go -C ./mtimer/ run . -root "$OUTPUT" -json "$PWD/mtimer.json"
  scp -i "$PWD/.secure_files/ssh.key" mtimer.json kdeos@origin.files.kde.org:/home/kdeos/mtimer.json
fi

rm -rfv "${OUTPUT}/efi"
[ -d "${OUTPUT}/efi" ] || mkdir --mode 0700 "${OUTPUT}/efi"
[ -d "${OUTPUT}/usr/share/factory/boot" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot"
[ -d "${OUTPUT}/usr/share/factory/boot/EFI" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/EFI"
[ -d "${OUTPUT}/usr/share/factory/boot/EFI/Linux" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/EFI/Linux"
[ -d "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$EFI_BASE.efi.extra.d" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$EFI_BASE.efi.extra.d"
cp -v "${OUTPUT}"/kde-linux.efi "$MAIN_UKI"
mv -v "${OUTPUT}"/kde-linux.efi "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$EFI"
mv -v "${OUTPUT}"/live.efi "$LIVE_UKI"
mv -v "${OUTPUT}"/erofs.addon.efi "${OUTPUT}_erofs.addon.efi"

make_debug_archive

mv "$LIVE_UKI" "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$EFI"

cd kde-linux.cache

fallocate -l 260M esp.raw
mkfs.fat -F 32 esp.raw
mkdir -p esp.raw.mnt
mount esp.raw esp.raw.mnt
cp --archive --recursive "${OUTPUT}/usr/share/factory/boot/." esp.raw.mnt
umount esp.raw.mnt

cp "$MAIN_UKI" "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$EFI"

cd ..

rm -rf "$OUTPUT/var/lib/flatpak"
mkdir "$OUTPUT/var/lib/flatpak"

time mkfs.erofs -zzstd -C 65536 --chunksize 65536 "$ROOTFS_EROFS" "$OUTPUT" > erofs.log 2>&1
cp --reflink=auto "$ROOTFS_EROFS" kde-linux.cache/root.raw

touch "$IMG"
systemd-repart --no-pager --empty=allow --size=auto --dry-run=no --root=kde-linux.cache --definitions=mkosi.repart "$IMG"

chown -R user:user mkosi.output

./basic-test.py "$IMG" "$EFI_BASE.efi" || exit 1
rm ./mkosi.output/*.test.raw

./torrent-create.rb "$VERSION" "$OUTPUT" "$IMG"

go install -v github.com/folbricht/desync/cmd/desync@latest
~/go/bin/desync make --print-stats --chunk-size 1024:2048:4096 "$ROOTFS_CAIBX" "$ROOTFS_EROFS"
cp "$ROOTFS_CAIBX" "$ROOTFS_EROFS.caibx"

tar -cf ${OUTPUT}_root-x86-64.tar -T /dev/null
zstd --threads=0 --rm ${OUTPUT}_root-x86-64.tar

chmod go+r "$OUTPUT".* ./mkosi.output/*.efi ./mkosi.output/*.torrent
ls -lah
