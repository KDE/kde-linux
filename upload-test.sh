#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>

set -eux

# The new s3 based upload system

S3_ROOT="s3+https://storage.kde.org/kde-linux"
S3_STORE="$S3_ROOT/sysupdate/store/"
S3_TARGET="$S3_ROOT/testing/"

wget https://files.kde.org/kde-linux/kde-linux_202508202317_root-x86-64.erofs
wget https://files.kde.org/kde-linux/kde-linux_202508202317_root-x86-64.erofs.caibx
mv kde-linux_202508202317_root-x86-64.erofs.caibx kde-linux_202508202317_root-x86-64.caibx

## Upload to the chunk store directly
go install -v github.com/folbricht/desync/cmd/desync@latest
go -C ./token-redeemer/ run .
cat ~/.aws/credentials
cat ~/.config/desync/config.json
~/go/bin/desync chop \
    --concurrency 16 \
    --store "$S3_STORE" \
    ./*-x86-64.caibx \
    ./*-x86-64.erofs
