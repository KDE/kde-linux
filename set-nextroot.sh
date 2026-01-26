#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>
# SPDX-FileCopyrightText: 2026 Nikolay Kochulin <basiqueevangelist@yandex.ru>

set -euo pipefail

# Mount a new root filesystem which can be used upon a soft reboot.
# This can be used to test locally-built images without needing to setup a new VM.

# To use, build an image. Then, with the produced kde-linux_*_root-*.erofs file,
# run this script with `sudo ./set-nextroot.sh kde-linux_*_root-*.erofs`.

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

if ! grep -q "^ID=kde-linux$" /etc/os-release; then
    echo "This script must be run on a KDE Linux system." >&2
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /path/to/new/root.erofs" >&2
    exit 1
fi

NEW_ROOT="$1"

if [[ ! -f "$NEW_ROOT" ]]; then
    echo "File $NEW_ROOT does not exist." >&2
    exit 1
fi

mkdir /run/nextroot
mount /dev/disk/by-designator/root /run/nextroot -o subvol=/@system
mount /dev/disk/by-designator/root /run/nextroot/system -o subvol=/
mount "$NEW_ROOT" /run/nextroot/usr -o X-mount.subdir=usr

echo "New root filesystem mounted at /run/nextroot."
echo "To switch to the new root, run: systemctl soft-reboot"
