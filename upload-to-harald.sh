#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

set -eux

for f in *.raw *.erofs; do
    curl --upload-file "$f" http://images.kde-linux.haraldsitter.eu/incoming/
done
