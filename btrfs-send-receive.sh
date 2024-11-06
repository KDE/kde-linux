#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2023 Harald Sitter <sitter@kde.org>

# Executed inside an image to populate the subvolume via btrfs snapshot magic

set -ex

OUTPUT_ABS=$1
OUTPUT=$2
ID=$3

[ "$OUTPUT_ABS" = "" ] && exit 1
[ "$OUTPUT" = "" ] && exit 1
[ "$ID" = "" ] && exit 1

OUTPUT_DIR=$(dirname "$OUTPUT_ABS")
EXPORT="$OUTPUT.export"

cleanup() {
    [ -d "$EXPORT" ] && btrfs subvolume delete "$EXPORT"
    btrfs filesystem show . || true
    btrfs filesystem df . || true
    dmesg > "$OUTPUT_DIR/dmesg.log"
    return 0
}
trap cleanup INT TERM EXIT
cleanup

mount -o remount,compress-force=zstd:15 "$PWD"
btrfs property set . compression zstd
btrfs balance start --force -mconvert=single -dconvert=single .

btrfs receive -f "$OUTPUT_ABS.btrfs" .
btrfs subvolume snapshot -r "$EXPORT" "@$OUTPUT"
btrfs subvolume delete "$EXPORT"
rm -f "$OUTPUT_ABS.btrfs"

btrfs receive -f "$OUTPUT_ABS.btrfs.flatpak" .
btrfs subvolume snapshot -r "$EXPORT.flatpak" "@flatpak"
btrfs subvolume delete "$EXPORT.flatpak"
rm -f "$OUTPUT_ABS.btrfs.flatpak"

btrfs receive -f "$OUTPUT_ABS.btrfs.live" .
btrfs subvolume snapshot -r "$EXPORT.live" "@live"
btrfs subvolume delete "$EXPORT.live"
rm -f "$OUTPUT_ABS.btrfs.live"

# Sync before we start to mess with the filesystem again. Otherwise we might make it fall over.
btrfs subvolume sync .
btrfs filesystem sync .

# Finally let's condense the data.
btrfs filesystem usage .
## Use duperemove to deduplicate files.
## I would also love to use bees here as it works on extents but we don't know when it is done :( https://github.com/Zygo/bees/issues/279
duperemove -dr . > /dev/null
btrfs subvolume sync .
btrfs filesystem sync .
btrfs balance start --full-balance --enqueue .
btrfs subvolume sync .
btrfs filesystem sync .
## And to finish things off we shrink the filesystem to the minimum size.
$OUTPUT_DIR/btrfs-shrink.py
## Sync changes to disk.
btrfs filesystem sync .
# Final report.
btrfs filesystem usage .

ln -svf "@$OUTPUT" "$ID"
