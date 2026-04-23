#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

set -eux

# ADDON_DIR is set by basic-test.py to the .extra.d directory inside the mounted ESP
if [ -z "$ADDON_DIR" ]; then
    echo "ERROR: ADDON_DIR environment variable not set"
    exit 1
fi

# Create the addon UKI (systemd-stub addon) that appends the test cmdline
ukify build \
    --cmdline "kde-linux.basic-test=1 kde-linux.basic-test-callback=http://10.0.2.2:${PORT}/good" \
    --output "$ADDON_DIR/basic-test.addon.efi"
