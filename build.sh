#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2023 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>

# Build image using mkosi, well, somewhat. mkosi is actually a bit too inflexible for our purposes so we generate a OS
# tree using mkosi and then construct shipable raw images (for installation) and tarballs (for systemd-sysupdate)
# ourselves.

set -ex

# Creates an archive containing the data from just the kde-linux-debug repository packages,
# essentially the debug symbols for KDE apps, to be used as a sysext.
make_debug_archive () {
  # Create an empty directory at /tmp/debugroot to install the packages to before compressing.
  rm --recursive --force /tmp/debugroot
  mkdir --parents /tmp/debugroot

  # Install all packages in the kde-linux-debug repository to /tmp/debugroot.
  pacstrap -c /tmp/debugroot $(pacman --sync --list --quiet kde-linux-debug)

  # systemd-sysext uses the os-release in extension-release.d to verify the sysext matches the base OS,
  # and can therefore be safely installed. Copy the base OS' os-release there.
  mkdir --parents /tmp/debugroot/usr/lib/extension-release.d/
  cp "${OUTPUT}/usr/lib/os-release" /tmp/debugroot/usr/lib/extension-release.d/extension-release.debug

  # Finally compress /tmp/debugroot/usr into a zstd tarball at $DEBUG_TAR.
  # We actually only need usr because that's where all the relevant stuff lays anyways.
  tar --directory=/tmp/debugroot --create --file="$DEBUG_TAR" usr
  zstd --threads=0 --rm "$DEBUG_TAR" # --threads=0 automatically uses the optimal number
}

EPOCH=$(date --utc +%s) # The epoch (only used to then construct the various date strings)
VERSION_DATE=$(date --utc --date="@$EPOCH" --rfc-3339=seconds)
VERSION=$(date --utc --date="@$EPOCH" +%Y%m%d%H%M)
OUTPUT=kde-linux_$VERSION   # Built rootfs path (mkosi uses this directory by default)

# Canonicalize the path in $OUTPUT to avoid any possible path issues.
OUTPUT="$(readlink --canonicalize-missing "$OUTPUT")"

MAIN_UKI=${OUTPUT}.efi               # Output main UKI path
LIVE_UKI=${OUTPUT}_live.efi          # Output live UKI path
DEBUG_TAR=${OUTPUT}_debug-x86-64.tar # Output debug archive path (.zst will be added)
ROOTFS_TAR=${OUTPUT}_root-x86-64.tar # Output rootfs tarball path (.zst will be added)
ROOTFS_EROFS=${OUTPUT}_root-x86-64.erofs # Output erofs image path
IMG=${OUTPUT}.raw                    # Output raw image path

EFI_BASE=kde-linux_${VERSION} # Base name of the UKI in the image's ESP (exported so it can be used in basic-test-efi-addon.sh)
EFI=${EFI_BASE}+3.efi # Name of primary UKI in the image's ESP

# Clean up old build artifacts.
rm --recursive --force kde-linux.cache/*.raw kde-linux.cache/*.mnt

export SYSTEMD_LOG_LEVEL=debug

# Make sure permissions are sound
./permission-fix.sh

cargo build --release --manifest-path btrfs-migrator/Cargo.toml
cp -v btrfs-migrator/target/release/_kde-linux-btrfs-migrator mkosi.extra/usr/bin/

mkosi \
    --environment="CI_COMMIT_SHORT_SHA=${CI_COMMIT_SHORT_SHA:-unknownSHA}" \
    --environment="CI_COMMIT_SHA=${CI_COMMIT_SHA:-unknownSHA}" \
    --environment="CI_PIPELINE_URL=${CI_PIPELINE_URL:-https://invent.kde.org}" \
    --environment="VERSION_DATE=${VERSION_DATE}" \
    --image-version="$VERSION" \
    --package-cache-dir=/var/cache/mkosi.pacman \
    --output-directory=. \
    "$@"

# NOTE: /efi must be empty so auto mounting can happen. As such we put our templates in a different directory
rm -rfv "${OUTPUT}/efi"
[ -d "${OUTPUT}/efi" ] || mkdir --mode 0700 "${OUTPUT}/efi"
[ -d "${OUTPUT}/usr/share/factory/boot" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot"
[ -d "${OUTPUT}/usr/share/factory/boot/EFI" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/EFI"
[ -d "${OUTPUT}/usr/share/factory/boot/EFI/Linux" ] || mkdir --mode 0700 "${OUTPUT}/usr/share/factory/boot/EFI/Linux"
cp -v "${OUTPUT}"/kde-linux.efi "$MAIN_UKI"
mv -v "${OUTPUT}"/kde-linux.efi "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$EFI"
mv -v "${OUTPUT}"/live.efi "$LIVE_UKI"

make_debug_archive

# Now let's actually build a live raw image. First, the ESP.
# We use kde-linux.cache instead of /tmp as usual because we'll probably run out of space there.

# Since we're building a live image, replace the main UKI with the live one.
cp "$LIVE_UKI" "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$EFI"

# Change to kde-linux.cache since we'll be working there.
cd kde-linux.cache

# Create a 260M large FAT32 filesystem inside of esp.raw.
fallocate -l 260M esp.raw
mkfs.fat -F 32 esp.raw

# Mount it to esp.raw.mnt.
mkdir -p esp.raw.mnt # The -p prevents failure if directory already exists
mount esp.raw esp.raw.mnt

# Copy everything from /usr/share/factory/boot into esp.raw.mnt.
cp --archive --recursive "${OUTPUT}/usr/share/factory/boot/." esp.raw.mnt

# We're done, unmount esp.raw.mnt.
umount esp.raw.mnt

# Now, the root.

# Copy back the main UKI for the root.
cp "$MAIN_UKI" "${OUTPUT}/usr/share/factory/boot/EFI/Linux/$EFI"

cd .. # and back to root

# Create rootfs tarball for consumption by systemd-sysext (doesn't currently support consuming raw images :()

# Currently our build machine's kernel doesn't support zstd so we use xz instead.
# This is a temporary workaround until the great CI VM transition happens and we can use a more recent kernel.
erofs_algorithm=zstd
algorithm_timeout=1751612936 # Friday, July 4, 2025 7:08:56 AM
if [ "$(date +%s)" -le $algorithm_timeout ]; then
  erofs_algorithm=deflate
fi
echo "Using erofs algorithm: $erofs_algorithm"

time mkfs.erofs -d0 "-z$erofs_algorithm" "$ROOTFS_EROFS" "$OUTPUT" > /dev/null 2>&1
cp --reflink=auto "$ROOTFS_EROFS" kde-linux.cache/root.raw

# Now assemble the two generated images using systemd-repart and the definitions in mkosi.repart into $IMG.
touch "$IMG"
systemd-repart --no-pager --empty=allow --size=auto --dry-run=no --root=kde-linux.cache --definitions=mkosi.repart "$IMG"

./basic-test.py "$IMG" "$EFI_BASE.efi" || exit 1

# Create a torrent for the image
./torrent-create.rb "$VERSION" "$OUTPUT" "$IMG"

# efi images and torrents are 700, make them readable so the server can serve them
chmod go+r "$OUTPUT".* ./*.efi ./*.torrent
ls -lah
