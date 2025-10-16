#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>

# Make sure user is root before starting
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or with run0"
  exit 1
fi

set -e

# Older installations may need ESP mounted in /efi to upgrade properly
if [ -d /efi ]; then
  # Trigger mount of ESP by accessing it.
  # TODO file bug that sysupdate doesn't do that.
  stat /efi/EFI 2>&1 > /dev/null || true
  if [ ! -d /efi/EFI ]; then
    rootdisk=/dev/disk/by-partlabel/KDELinux
    if [ -b /dev/gpt-auto-root ]; then
        # When the partition was auto detected we can just use the auto-root device
        rootdisk=/dev/gpt-auto-root
    elif [ -b /dev/disk/by-partlabel/KDEOS ]; then
        rootdisk=/dev/disk/by-partlabel/KDEOS # Fallback for older images
    fi

    espdev=$(/usr/lib/find-esp "$rootdisk")
    mount "$espdev" "$ROOT/efi"
  fi
fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

SYSTEMD_VERSION=$(busctl --json=short get-property org.freedesktop.systemd1 /org/freedesktop/systemd1 org.freedesktop.systemd1.Manager Version)
SYSTEMD_VERSION=$(echo "$SYSTEMD_VERSION" | jq '.["data"]')
if systemd-analyze compare-versions "$SYSTEMD_VERSION" '<=' 257; then
  # earlier versions of systemd-pull didn't support zstd natively so we hacked it in via TAR_OPTIONS
  export TAR_OPTIONS="--zstd"
fi

# FIXME set up signing shebang so we can run with verify
exec systemd-inhibit \
  --what=sleep:shutdown \
  --mode=block \
  --who="KDE Linux Updater" \
  --why="Updating System" \
  /usr/lib/systemd/systemd-sysupdate \
    --definitions="$SCRIPT_DIR/mkosi.extra/usr/lib/sysupdate.d" \
    --verify=no \
    "$@"
