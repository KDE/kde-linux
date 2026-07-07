#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2023 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

# Build image using mkosi, well, somewhat. mkosi is actually a bit too inflexible for our purposes so we generate a OS
# tree using mkosi and then construct shipable .iso9660 (and gpt raw disk images) for installation and tarballs (for systemd-sysupdate)
# ourselves.

set -ex

# Creates a sysext containing the KDE debug symbols, downloaded from the packages pipeline.
make_debug_archive () {
  # Create an empty directory at /var/tmp/debugroot to extract the debug symbols into before compressing.
  rm --recursive --force /var/tmp/debugroot
  mkdir --parents /var/tmp/debugroot

  # Download and extract debug symbols produced by the packages pipeline.
  if [ "${CI_COMMIT_BRANCH:-}" = "master" ]; then
    curl --fail https://storage.kde.org/kde-linux-packages/testing/artifacts/debug.tar.zst \
      | zstd --decompress | tar --extract --directory=/var/tmp/debugroot
  else
    curl --fail https://storage.kde.org/ci-artifacts/kde-linux/kde-linux-packages/j/4672389/testing/artifacts/debug.tar.zst \
      | zstd --decompress | tar --extract --directory=/var/tmp/debugroot
  fi

  # systemd-sysext uses the os-release in extension-release.d to verify the sysext matches the base OS,
  # and can therefore be safely installed. Copy the base OS' os-release there.
  mkdir --parents /var/tmp/debugroot/usr/lib/extension-release.d/
  cp "${OUTPUT}/usr/lib/os-release" /var/tmp/debugroot/usr/lib/extension-release.d/extension-release.debug

  # Compress /var/tmp/debugroot/usr into a zstd tarball at $DEBUG_TAR.
  # We only need usr because that's where all the relevant stuff lives.
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

EFI_BASE=kde-linux_${VERSION} # Base name of the UKI in the image's ESP
EFI=${EFI_BASE}+3.efi      # Name of primary UKI in the image's ESP (with tries counter for installed system)
LIVE_EFI=${EFI_BASE}.efi   # Name of live UKI in the ESP (no tries counter — ESP is read-only on ISO)

# Clean up old build artifacts.
rm --recursive --force kde-linux.cache/*.raw kde-linux.cache/*.iso kde-linux.cache/*.mnt

BUILDSTREAM_ROOTFS="buildstream-rootfs"
BUILDSTREAM_BOOTFS="buildstream-bootfs"
BUILDSTREAM_TOOLFS="buildstream-toolfs"
BUILDSTREAM_EFI="buildstream-efi"

cat <<EOF > "include/kde-linux-image.yml"
# SPDX-FileCopyrightText: 2026 KDE Linux Contributors
# SPDX-License-Identifier: BSD-2-Clause

variables:
  kde-linux-version-date: '${VERSION_DATE}'
  kde-linux-image-version: '${VERSION}'
  kde-linux-build-id: '${CI_COMMIT_SHORT_SHA:-unknownSHA}'
  kde-linux-commit-sha: '${CI_COMMIT_SHA:-unknownSHA}'
  kde-linux-commit-short-sha: '${CI_COMMIT_SHORT_SHA:-unknownSHA}'
  kde-linux-ci-url: '${CI_PIPELINE_URL:-https://invent.kde.org}'
EOF

mkdir -p "$PWD/mkosi.extra/usr/lib"

cargo build --release --manifest-path btrfs-migrator/Cargo.toml
cp -v btrfs-migrator/target/release/btrfs-migrator mkosi.extra/usr/lib/

rm --recursive --force kde-linux-sysupdated
git clone https://invent.kde.org/kde-linux/kde-linux-sysupdated
DESTDIR=$PWD/mkosi.extra make --directory=kde-linux-sysupdated install

rm --recursive --force etc-factory
git clone https://invent.kde.org/kde-linux/etc-factory
DESTDIR=$PWD/mkosi.extra make --directory=etc-factory install

if [ "${KDECI_BUILD:-}" = "TRUE" ]; then
    # Set up cache overrides
    mkdir --parents ~/.config
    cp buildstream.conf ~/.config/buildstream.conf
fi

rm -rf "$BUILDSTREAM_ROOTFS" "$BUILDSTREAM_BOOTFS" "$BUILDSTREAM_TOOLFS" "$BUILDSTREAM_EFI"
bst build \
    os/filesystem.bst \
    os/initrd.bst \
    kde-linux-packages.bst:kde-buildstream.bst:components/calamares.bst \
    kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/ovmf-maybe.bst \
    kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:vm/prepare-image.bst
bst artifact checkout os/filesystem.bst --directory $BUILDSTREAM_ROOTFS
bst artifact checkout os/initrd.bst --directory $BUILDSTREAM_BOOTFS
bst artifact checkout kde-linux-packages.bst:kde-buildstream.bst:components/calamares.bst --deps none --directory $BUILDSTREAM_ROOTFS/live
bst artifact checkout kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:vm/prepare-image.bst --deps none --directory $BUILDSTREAM_TOOLFS
bst artifact checkout kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/ovmf-maybe.bst --directory $BUILDSTREAM_EFI

mkdir -p $BUILDSTREAM_ROOTFS/usr/share/ovmf/
cp $BUILDSTREAM_EFI/usr/share/ovmf/Shell.efi $BUILDSTREAM_ROOTFS/usr/share/ovmf/Shell.efi

# Make sure permissions are sound
./permission-fix.sh

if [ "${CI_COMMIT_BRANCH:-}" = "master" ]; then
  wget --output-document=install.tar.zst https://storage.kde.org/kde-linux-packages/testing/artifacts/install.tar.zst
else
  wget --output-document=install.tar.zst https://storage.kde.org/ci-artifacts/kde-linux/kde-linux-packages/j/4672389/testing/artifacts/install.tar.zst
fi

mkosi \
    --image-version="$VERSION" \
    --extra-tree $BUILDSTREAM_BOOTFS:/boot \
    --extra-tree="$PWD/install.tar.zst" \
    --extra-tree="$PWD/mkosi.extra" \
    "$@"

# Adjust mtime to reduce unnecessary churn between images caused by us rebuilding repos that have possibly not changed in source or binary interfaces.
if [ -f "$PWD/.secure_files/ssh.key" ]; then
  # You can use `ssh-keyscan origin.files.kde.org` to get the host key
  echo "origin.files.kde.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUjdH4S7otYIdLUkOZK+owIiByjNQPzGi7GQ5HOWjO6" >> ~/.ssh/known_hosts

  chmod 600 "$PWD/.secure_files/ssh.key"

  scp -i "$PWD/.secure_files/ssh.key" kdeos@origin.files.kde.org:/home/kdeos/mtimer.json mtimer.json
  # Note: use absolute paths. since we chdir via go
  go -C ./mtimer/ run . -root "$OUTPUT" -json "$PWD/mtimer.json"
  scp -i "$PWD/.secure_files/ssh.key" mtimer.json kdeos@origin.files.kde.org:/home/kdeos/mtimer.json
fi

chmod u+w "$OUTPUT" # mkosi tries to be nice by making it read-only
# NOTE: /efi must be empty so auto mounting can happen. As such we put our templates in a different directory
rm -rfv "${OUTPUT}/efi"
[ -d "${OUTPUT}/efi" ] || mkdir --mode 0700 "${OUTPUT}/efi"
[ -d "${OUTPUT}/usr/share/factory/boot" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot"
[ -d "${OUTPUT}/usr/share/factory/boot/EFI" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/EFI"
[ -d "${OUTPUT}/usr/share/factory/boot/EFI/Linux" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/EFI/Linux"
[ -d "${OUTPUT}/usr/share/factory/boot/loader" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/loader"
[ -d "${OUTPUT}/usr/share/factory/boot/loader/entries" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/loader/entries"
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

# Create a 560M large FAT32 filesystem inside of esp.raw.
fallocate -l 560M esp.raw
mkfs.fat -F 32 esp.raw
mcopy -i esp.raw -s "${OUTPUT}/usr/share/factory/boot/"* ::/

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

rm -f "${OUTPUT}/etc/resolv.conf"
ln -s ../run/systemd/resolve/stub-resolv.conf "${OUTPUT}/etc/resolv.conf"
# TODO: prune static archives in BuildStream/package composition instead of here.
find "${OUTPUT}" -xdev -type f -name '*.a' -print -delete
# Needs sudo because it sets caps
sudo SOURCE_DATE_EPOCH=1320937200 $BUILDSTREAM_TOOLFS/usr/bin/prepare-image.sh --sysroot $OUTPUT --initscripts $OUTPUT/etc/fdsdk/initial_scripts --noroot --nodepmod --noboot
bash -x check-fs.sh "${OUTPUT}"
install -D -m 0644 "$OUTPUT/etc/shells" "$OUTPUT/usr/share/factory/etc/shells"
# Needs sudo so it can tinker with setuid files
time sudo mkfs.erofs --all-root -zzstd -C 65536 --chunksize 65536 "$ROOTFS_EROFS" "$OUTPUT" > erofs.log 2>&1
# Then chown back the result
sudo chown $UID:$UID "$ROOTFS_EROFS"
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

# Create a torrent for the image
./torrent-create.rb "$VERSION" "$OUTPUT" "$ISO"

go install -v github.com/folbricht/desync/cmd/desync@latest
~/go/bin/desync make --print-stats --chunk-size 1024:2048:4096 "$ROOTFS_CAIBX" "$ROOTFS_EROFS"
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
