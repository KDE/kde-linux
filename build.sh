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
  zstd --threads=0 --rm -15 "$DEBUG_TAR" # --threads=0 automatically uses the optimal number
}

download_flatpaks() {
    [ -f /usr/lib/os-release ] || false
    cat /usr/lib/os-release

    mkdir flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    # Do this separately, when used as part of remote-add it complains about GPG for unknown reasons
    flatpak remote-modify --collection-id=org.flathub.Stable flathub

    # Only check out en. We don't really support other languages on the live image at this time.
    flatpak config --set languages en

    flatpak install --noninteractive --assumeyes \
        org.kde.ark \
        org.kde.dolphin \
        org.kde.elisa \
        org.kde.gwenview \
        org.kde.kate \
        org.kde.haruna \
        org.kde.konsole \
        org.kde.kwrite \
        org.kde.okular \
        org.mozilla.firefox

    # And restore default
    flatpak config --unset languages
}



VERSION=$(date +%Y%m%d%H%M) # Build version, will just be YYYYmmddHHMM for now
OUTPUT=kde-linux_$VERSION   # Built rootfs path (mkosi uses this directory by default)

# Canonicalize the path in $OUTPUT to avoid any possible path issues.
OUTPUT="$(readlink --canonicalize-missing "$OUTPUT")"

MAIN_UKI=${OUTPUT}.efi               # Output main UKI path
LIVE_UKI=${OUTPUT}_live.efi          # Output live UKI path
DEBUG_TAR=${OUTPUT}_debug-x86-64.tar # Output debug archive path (.zst will be added)
ROOTFS_TAR=${OUTPUT}_root-x86-64.tar # Output rootfs tarball path (.zst will be added)
IMG=${OUTPUT}.raw                    # Output raw image path

EFI=kde-linux_${VERSION}+3.efi # Name of primary UKI in the image's ESP

# Clean up old build artifacts.
rm --recursive --force kde-linux.cache/*.raw kde-linux.cache/*.mnt

export SYSTEMD_LOG_LEVEL=debug

# Make sure permissions are sound
./permission-fix.sh

mkosi \
    --environment="CI_COMMIT_SHORT_SHA=${CI_COMMIT_SHORT_SHA:-unknownSHA}" \
    --environment="CI_COMMIT_SHA=${CI_COMMIT_SHA:-unknownSHA}" \
    --environment="CI_PIPELINE_URL=${CI_PIPELINE_URL:-https://invent.kde.org}" \
    --image-version="$VERSION" \
    --package-cache-dir=/var/cache/mkosi.pacman \
    --output-directory=. \
    "$@"

# Create a directory structure for the UKIs.
mkdir --parents "${OUTPUT}/efi/EFI/Linux"
chmod --recursive 0700 "${OUTPUT}/efi"

# Move the UKIs to their appropriate places.
cp "${OUTPUT}/kde-linux.efi" "$MAIN_UKI"
mv "${OUTPUT}/kde-linux.efi" "${OUTPUT}/efi/EFI/Linux/$EFI"
mv "${OUTPUT}/live.efi" "$LIVE_UKI"

make_debug_archive

# Now let's actually build a live raw image. First, the ESP.
# We use kde-linux.cache instead of /tmp as usual because we'll probably run out of space there.

# Since we're building a live image, replace the main UKI with the live one.
cp "$LIVE_UKI" "${OUTPUT}/efi/EFI/Linux/$EFI"

# Change to kde-linux.cache since we'll be working there.
cd kde-linux.cache

# Create a 260M large FAT32 filesystem inside of esp.raw.
fallocate -l 260M esp.raw
mkfs.fat -F 32 esp.raw

# Mount it to esp.raw.mnt.
mkdir esp.raw.mnt
mount esp.raw esp.raw.mnt

# Copy everything from /efi into esp.raw.mnt.
cp --archive --recursive "${OUTPUT}/efi/." esp.raw.mnt

# We're done, unmount esp.raw.mnt.
umount esp.raw.mnt

# Now, the root.

# Copy back the main UKI for the root.
cp "$MAIN_UKI" "${OUTPUT}/efi/EFI/Linux/$EFI"

# Create an 8G large btrfs filesystem inside of root.raw.
# Don't fret, we'll shrink this down to however much we actually need later.
fallocate -l 8G root.raw
mkfs.btrfs -L KDELinuxLive root.raw

# Mount it to root.raw.mnt.
mkdir root.raw.mnt
mount -o compress-force=zstd:15 root.raw root.raw.mnt

# Change to root.raw.mnt since we'll be working there.
cd root.raw.mnt

# Enable compression filesystem-wide.
btrfs property set . compression zstd:15

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

download_flatpaks

# Create read-only subvolumes from chroot's /live and /.
# and from the container's /var/lib/flatpak.
cp --archive --recursive "${OUTPUT}/live/." @live
cp --archive --recursive "/var/lib/flatpak/." @flatpak
rm --recursive "${OUTPUT}/live"
cp --archive --recursive "${OUTPUT}/." "@kde-linux_$VERSION"
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

# How much we'll keep shrinking the filesystem by, in bytes.
# Too large = too imprecise, too small = shrink is too slow.
# One mebibyte seems good for now.
SHRINK_AMOUNT=1048576

# Repeatedly shrink the filesystem by $SHRINK_AMOUNT until we get an error.
# Store the size it has been successfully shrunk by in $SHRINK_SIZE.
SHRINK_SIZE=0
while true; do
  btrfs filesystem resize -$SHRINK_AMOUNT . || break
  SHRINK_SIZE=$((SHRINK_SIZE + SHRINK_AMOUNT))
  btrfs filesystem sync .
done

# Back out to kde-linux.cache, then unmount root.raw.mnt.
cd ..
umount root.raw.mnt

# We shrunk the filesystem, but root.raw as a file itself is still 8G.
# Let's safely truncate it by the previously stored $SHRINK_SIZE.
truncate --size=-$SHRINK_SIZE root.raw

# We're done, back out of kde-linux.cache into the root.
cd ..

# Create rootfs tarball for consumption by systemd-sysext (doesn't currently support consuming raw images :()
rm -rf "$ROOTFS_TAR" ./*.tar
tar -C "${OUTPUT}"/ --xattrs --xattrs-include=*.* -cf "$ROOTFS_TAR" .
zstd -T0 --rm "$ROOTFS_TAR"

# Now assemble the two generated images using systemd-repart and the definitions in mkosi.repart into $IMG.
touch "$IMG"
systemd-repart --no-pager --empty=allow --size=auto --dry-run=no --root=kde-linux.cache --definitions=mkosi.repart "$IMG"

# Create a torrent for the image
./torrent-create.rb "$VERSION" "$OUTPUT" "$IMG"

# TODO before accepting new uploads perform sanity checks on the artifacts (e.g. the tar being well formed)

# efi images and torrents are 700, make them readable so the server can serve them
chmod go+r "$OUTPUT".* ./*.efi ./*.torrent
ls -lah
