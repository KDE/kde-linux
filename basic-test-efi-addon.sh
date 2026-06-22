#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

set -eux

cd boot/EFI/Linux/

dir="$UKI.extra.d"
[ -d "$dir" ] || mkdir "$dir"
ukify build \
  --cmdline "kde-linux.basic-test=1 kde-linux.basic-test-callback=http://10.0.2.2:${PORT}/good" \
  --output "$dir/basic-test.addon.efi"
