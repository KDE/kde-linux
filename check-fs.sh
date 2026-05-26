#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

OUTPUT=$1

# Safety nets to prevent excessive breakage
## sudo should have sticky bit set
[ -u $OUTPUT/usr/bin/sudo ] || exit 1
## newuidmap should have a capability set
[ "$(getcap $OUTPUT/usr/bin/newuidmap)" != "" ] || exit 1
