#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2023 Harald Sitter <sitter@kde.org>

# Build image using mkosi, well, somewhat. mkosi is actually a bit too inflexible for our purposes so we generate a OS
# tree using mkosi and then construct shipable raw images (for installation) and tarballs (for systemd-sysupdate)
# ourselves.

# TODO port to ruby or python or something. it's getting too long for sh

set -ex

NAME=kde-linux
_EPOCH=$(date +%s)
_DATE=$(date --date="@$_EPOCH" +%Y%m%d)
_TIME=$(date --date="@$_EPOCH" +%H%M)
DATETIME="${_DATE}${_TIME}"
VERSION="$DATETIME"
OUTPUT=${NAME}_$VERSION
EFI=$OUTPUT+3.efi # +3 is the default boot number for systemd-boot
TAR=${OUTPUT}_root-x86-64.tar
IMG=$OUTPUT.raw

export SYSTEMD_LOG_LEVEL=debug

cat <<- EOF > mkosi.conf.d/00-environment.conf
[Content]
@Environment=CI_COMMIT_SHORT_SHA=${CI_COMMIT_SHORT_SHA:-unknownSHA}
@Environment=CI_COMMIT_SHA=${CI_COMMIT_SHA:-unknownSHA}
@Environment=CI_PIPELINE_URL=${CI_PIPELINE_URL:-htts://invent.kde.org}
EOF

cat <<- EOF > mkosi.conf.d/00-outputdirectory.conf
[Output]
OutputDirectory=${PWD}
EOF

# Make sure permissions are sound
./permission-fix.py

mkosi \
    --distribution arch \
    --image-id "$NAME" \
    --image-version "$VERSION" \
    "$@"

# NOTE: /efi must be empty so auto mounting can happen. As such we put our templates in a different directory
rm -rfv "${OUTPUT}/efi"
[ -d "${OUTPUT}/efi" ] || mkdir --mode 0700 "${OUTPUT}/efi"
[ -d "${OUTPUT}/efi-template" ] || mkdir --mode 0700 "${OUTPUT}/efi-template"
[ -d "${OUTPUT}/efi-template/EFI" ] || mkdir --mode 0700 "${OUTPUT}/efi-template/EFI"
[ -d "${OUTPUT}/efi-template/EFI/Linux" ] || mkdir --mode 0700 "${OUTPUT}/efi-template/EFI/Linux"
cp -v "${OUTPUT}"/${NAME}*.efi "$OUTPUT.efi"
mv -v "${OUTPUT}"/${NAME}*.efi "${OUTPUT}/efi-template/EFI/Linux/$EFI"
mv -v "${OUTPUT}"/live.efi "${OUTPUT}_live.efi"

OUTPUT_IS_BTRFS_SUBVOLUME=false
if [ "$(stat --file-system --format %T "$OUTPUT")" = "btrfs" ] && [ "$(stat --format %i "$OUTPUT")" = "256" ]; then
    OUTPUT_IS_BTRFS_SUBVOLUME=true
fi

# Move debug tarball out of the tree
mv -v "$OUTPUT/debug.tar.zst" "${OUTPUT}_debug-x86-64.tar.zst"

FLATPAK_SIZE=""
# Move /flatpak out of the tree and into subvolume
if $OUTPUT_IS_BTRFS_SUBVOLUME; then
    btrfs subvolume create "$OUTPUT.flatpak"
    cp -rf --reflink=always "$OUTPUT/flatpak/." "$OUTPUT.flatpak"
    rm -rf "$OUTPUT/flatpak"
    # Note that compression is applied on a mount-level via the host system.
    compsize "$OUTPUT.flatpak"
    btrfs subvolume snapshot -r "$OUTPUT.flatpak" "$OUTPUT.export.flatpak"
    btrfs send --compressed-data -f "$OUTPUT.btrfs.flatpak" "$OUTPUT.export.flatpak"
    btrfs subvolume delete "$OUTPUT.export.flatpak"
    FLATPAK_SIZE=$(stat --format %s "$OUTPUT.btrfs.flatpak") # the actual size of all data
fi

LIVE_SIZE=""
# Move /live out of the tree and into subvolume
if $OUTPUT_IS_BTRFS_SUBVOLUME; then
    btrfs subvolume create "$OUTPUT.live"
    cp -rf --reflink=always "$OUTPUT/live/usr/." "$OUTPUT.live/usr"
    rm -rf "$OUTPUT/live"
    # Note that compression is applied on a mount-level via the host system.
    compsize "$OUTPUT.live"
    btrfs subvolume snapshot -r "$OUTPUT.live" "$OUTPUT.export.live"
    btrfs send --compressed-data -f "$OUTPUT.btrfs.live" "$OUTPUT.export.live"
    btrfs subvolume delete "$OUTPUT.export.live"
    LIVE_SIZE=$(stat --format %s "$OUTPUT.btrfs.live") # the actual size of all data
fi

# Create rootfs tarball for consumption by systemd-sysext (doesn't currently support consuming raw images :()
rm -rf "$TAR" ./*.tar
tar -C "${OUTPUT}"/ -cf "$TAR" .
SIZE=$(stat --format %s "$TAR") # the apparent size of all data
zstd -T0 --rm "$TAR"

# Accurate sizing is a bit of a challenge. In the most ideal scenario we'll be working on btrfs and are able to
# compress the entire subvolume into a file. This file size will then be more or less the DATA size in the filesystem.
# On top of that we have the btrfs meta data and system data, these are kind of dependent on the actual partition size
# but will generally be ~768M (this value entirely depends on how many files we have) and <50M for partitions <50G.
if $OUTPUT_IS_BTRFS_SUBVOLUME; then
    # Note that compression is applied on a mount-level via the host system.
    compsize "$OUTPUT"
    btrfs subvolume snapshot -r "$OUTPUT" "$OUTPUT.export"
    btrfs send --compressed-data -f "$OUTPUT.btrfs" "$OUTPUT.export"
    btrfs subvolume delete "$OUTPUT.export"
    SIZE=$(stat --format %s "$OUTPUT.btrfs") # the actual size of all data
    SIZE=$((SIZE+2147483648)) # 2G slack -- this needs to be sufficient for our deduplication and balancing run. We'll shrink this way down later.
else
    SIZE=$((SIZE+4294967296)) # 4G slack (our guess is less precise without btrfs)
fi
SIZE=$((SIZE+FLATPAK_SIZE)) # however much we need for flatpak
SIZE=$((SIZE+LIVE_SIZE)) # however much we need for live data
SIZE=$((SIZE+851443712)) # 768M for btrfs metadata, 44M for system block
SIZE=$((SIZE+536870912)) # 512M for ESP

rm -f "$IMG" ./*.raw
touch "$IMG"
# The root partition contains the shipable efi image for use on the installed system.
systemd-repart --no-pager --empty=allow --size="$SIZE" --dry-run=no --root="${OUTPUT}" --definitions=mkosi.repart --defer-partitions=esp "$IMG"
if $OUTPUT_IS_BTRFS_SUBVOLUME; then # btrfs subvolume
    systemd-dissect --with "$IMG" "$(pwd)/btrfs-send-receive.sh" "$PWD/$OUTPUT" "$OUTPUT" "@$NAME"
else # do a raw copy
    systemd-dissect --with "$IMG" "$(pwd)/btrfs-copy.sh" "$PWD/$OUTPUT" "$OUTPUT" "@$NAME"
fi
# The esp of the image contains the live efi image (divergent cmdline).
# We copy into efi-template for convenience, it won't actually be used from there, just copied by systemd-repart.
cp -v "${OUTPUT}_live.efi" "${OUTPUT}/efi-template/EFI/Linux/$EFI"
systemd-repart --no-pager --empty=allow --size=auto --dry-run=no --root="${OUTPUT}" --definitions=mkosi.repart --defer-partitions=root "$IMG"

# Finally rebuild the actual image file with appropriate partition sizing. In particular with squeezed btrfs.
./part-rebuild.py "$IMG"

# Create a torrent for the image
./torrent-create.rb "$VERSION" "$OUTPUT" "$IMG"

# TODO before accepting new uploads perform sanity checks on the artifacts (e.g. the tar being well formed)

# efi images and torrents are 700, make them readable so the server can serve them
chmod go+r ./"$OUTPUT".* ./*.efi ./*.torrent
ls -lah
