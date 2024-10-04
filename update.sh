#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>

# Make sure user is root before starting
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or with run0"
  exit 1
fi

set -e

# Trigger mount of ESP by accessing it.
# TODO file bug that sysupdate doesn't do that.
stat /efi/EFI

export TAR_OPTIONS="--zstd"
# FIXME set up signing shebang so we can run with verify
exec systemd-inhibit --what=sleep:shutdown --mode=block --who="KDE Linux Updater" --why="Updating System" /usr/lib/systemd/systemd-sysupdate --verify=no "$@"
