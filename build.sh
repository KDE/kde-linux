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

ZSTD_LEVEL=3 # Compression level for zstd (3 = default of erofs as well)
if [ "$CI_COMMIT_BRANCH" = "$CI_DEFAULT_BRANCH" ]; then
  # If we are on the default branch, use the highest compression level.
  ZSTD_LEVEL=15
fi

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
[ -d "${OUTPUT}/efi-template" ] || mkdir --mode 0700 "${OUTPUT}/efi-template"
[ -d "${OUTPUT}/efi-template/EFI" ] || mkdir --mode 0700 "${OUTPUT}/efi-template/EFI"
[ -d "${OUTPUT}/efi-template/EFI/Linux" ] || mkdir --mode 0700 "${OUTPUT}/efi-template/EFI/Linux"
cp -v "${OUTPUT}"/kde-linux.efi "$MAIN_UKI"
mv -v "${OUTPUT}"/kde-linux.efi "${OUTPUT}/efi-template/EFI/Linux/$EFI"
mv -v "${OUTPUT}"/live.efi "$LIVE_UKI"

make_debug_archive

# Now let's actually build a live raw image. First, the ESP.
# We use kde-linux.cache instead of /tmp as usual because we'll probably run out of space there.

# Since we're building a live image, replace the main UKI with the live one.
cp "$LIVE_UKI" "${OUTPUT}/efi-template/EFI/Linux/$EFI"

# Change to kde-linux.cache since we'll be working there.
cd kde-linux.cache

# Create a 260M large FAT32 filesystem inside of esp.raw.
fallocate -l 260M esp.raw
mkfs.fat -F 32 esp.raw

# Mount it to esp.raw.mnt.
mkdir -p esp.raw.mnt # The -p prevents failure if directory already exists
mount esp.raw esp.raw.mnt

# Copy everything from /efi-template into esp.raw.mnt.
cp --archive --recursive "${OUTPUT}/efi-template/." esp.raw.mnt

# We're done, unmount esp.raw.mnt.
umount esp.raw.mnt

# Now, the root.

# Copy back the main UKI for the root.
cp "$MAIN_UKI" "${OUTPUT}/efi-template/EFI/Linux/$EFI"

# Create an 8G large btrfs filesystem inside of root.raw.
# Don't fret, we'll shrink this down to however much we actually need later.
fallocate -l 8G root.raw
mkfs.btrfs -L KDELinuxLive root.raw

# Mount it to root.raw.mnt.
mkdir -p root.raw.mnt # The -p prevents failure if directory already exists
mount -o compress-force=zstd:${ZSTD_LEVEL} root.raw root.raw.mnt

# Change to root.raw.mnt since we'll be working there.
cd root.raw.mnt

# Enable compression filesystem-wide.
btrfs property set . compression zstd:${ZSTD_LEVEL}

# Store both data and metadata only once for more compactness.
btrfs balance start --force -mconvert=single -dconvert=single .

# Create all the subvolumes we need.
btrfs subvolume create \
    @home \
    @root \
    @locale \
    @snap \
    @etc-overlay \
    @var-overlay \
    @live \
    @flatpak \
    "@kde-linux_$VERSION"

mkdir @etc-overlay/upper \
    @etc-overlay/work \
    @var-overlay/upper \
    @var-overlay/work

# For performance reasons we now transfer the entire subvolume into our mount point. This is a deep copy but by streaming
# the entire subvolume is much faster than doing a file-by-file copy instead. Still. This is a major bottleneck.
btrfs property set "${OUTPUT}" ro true
time btrfs send "${OUTPUT}" | btrfs receive .
OUTPUT_NAME=$(basename "${OUTPUT}")
# make writable
mv "${OUTPUT_NAME}" "${OUTPUT_NAME}.ro"
btrfs subvolume snapshot "${OUTPUT_NAME}.ro" "${OUTPUT_NAME}"
btrfs subvolume delete "${OUTPUT_NAME}.ro"

# Create read-only subvolumes from chroot's /live, /var/lib/flatpak, and /.
# mv what we can move to improve speed. when copying force reflinks, also for speed reasons.
mv ${OUTPUT_NAME}/live/* @live/
mv ${OUTPUT_NAME}/var/lib/flatpak/* @flatpak/
time cp --reflink=always --recursive --archive "${OUTPUT_NAME}/." "@kde-linux_$VERSION"
btrfs subvolume delete "${OUTPUT_NAME}"
btrfs property set @live ro true
btrfs property set @flatpak ro true
btrfs property set "@kde-linux_$VERSION" ro true

# Make a symlink called @kde-linux to the rootfs subvolume.
ln --symbolic "@kde-linux_$VERSION" @kde-linux

# Make sure everything is written before we continue.
btrfs filesystem sync .

# Optimize the filesystem for better shrinking/performance.
btrfs filesystem defragment -r .
btrfs filesystem sync .
duperemove -rdq .
btrfs filesystem sync .
btrfs balance start --full-balance --enqueue .
btrfs filesystem sync .

cd .. # up to kde-linux.cache
time ../btrfs-shrink-and-umount.py
cd .. # and back to root

# Create rootfs tarball for consumption by systemd-sysext (doesn't currently support consuming raw images :()
rm -rf "$ROOTFS_TAR" ./*.tar
time tar -C "${OUTPUT}"/ --xattrs --xattrs-include=*.* -cf "$ROOTFS_TAR" .
time zstd -T0 --rm "$ROOTFS_TAR"

time mkfs.erofs -d0 -zzstd "$ROOTFS_EROFS" "$OUTPUT" > /dev/null 2>&1

# Now assemble the two generated images using systemd-repart and the definitions in mkosi.repart into $IMG.
touch "$IMG"
systemd-repart --no-pager --empty=allow --size=auto --dry-run=no --root=kde-linux.cache --definitions=mkosi.repart "$IMG"

./basic-test.py "$IMG" "$EFI_BASE.efi" || exit 1

# Create a torrent for the image
./torrent-create.rb "$VERSION" "$OUTPUT" "$IMG"

# TODO before accepting new uploads perform sanity checks on the artifacts (e.g. the tar being well formed)

# efi images and torrents are 700, make them readable so the server can serve them
chmod go+r "$OUTPUT".* ./*.efi ./*.torrent
ls -lah
