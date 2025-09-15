#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>

set -eux

go -C ./token-redeemer/ run .
for caibx in *.erofs.caibx; do
  erofs="$(basename --suffix .caibx "$caibx")"

  ~/go/bin/desync chop \
    --store "s3+https://storage.kde.org/ci-artifacts/$CI_PROJECT_PATH/p/$CI_PIPELINE_ID/" \
    "$caibx" \
    "$erofs"
done
