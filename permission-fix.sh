#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>

# Something in GitLab causes bogus permissions to be set for mkosi input
# trees, reset them to something sane.
#
# Only touch the source directories mkosi consumes directly. In particular,
# do not recurse into generated trees such as a stale mkosi.output because
# that can make this step unexpectedly expensive.

DIRS="mkosi.conf.d mkosi.extra mkosi.finalize.d mkosi.repart mkosi.sandbox mkosi.skeleton"

find $DIRS -type d -exec chmod 755 {} + # ensure all directories are rwxr-xr-x
find $DIRS -type f -perm /111 -exec chmod 755 {} + # ensure all executable files (-perm filters by permission) has rwxr-xr-x
find $DIRS -type f ! -perm /111 -exec chmod 644 {} +
