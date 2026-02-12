# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

# Setup env correctly

export PATH="$HOME/.local/bin:$HOME/.local/sbin:/opt/local/sbin:/opt/local/bin:$PATH"

export XDG_DATA_DIRS="$HOME/.local/share:/opt/local/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

export XDG_CONFIG_DIRS="$HOME/.config:/opt/local/etc/xdg:${XDG_CONFIG_DIRS:-/etc/xdg}"

export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig:/opt/local/lib/pkgconfig:/opt/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"

export MANPATH="$HOME/.local/share/man:/opt/local/man:${MANPATH:-}:"
