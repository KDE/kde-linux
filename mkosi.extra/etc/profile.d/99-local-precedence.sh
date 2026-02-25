# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

# Setup PATH to let ~/.local and after that /opt/local mask everything
export PATH="$HOME/.local/bin:$HOME/.local/sbin:/opt/local/sbin:/opt/local/bin:$PATH"

# Prefixes
export LOCAL_PREFIX=/opt/local
export PREFIX=/opt/local
export DESTDIR=/opt/local

# For .desktop files and systemd
export XDG_DATA_DIRS="$HOME/.local/share:/opt/local/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_CONFIG_DIRS="$HOME/.config:/opt/local/etc/xdg:${XDG_CONFIG_DIRS:-/etc/xdg}"

# pkgconfig
export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig:/opt/local/lib/pkgconfig:/opt/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
