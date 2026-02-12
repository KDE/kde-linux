#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025-2026 Harald Sitter <sitter@kde.org>

set -eux

if [ ! -d upload-tree ]; then
    mkdir upload-tree
    for f in *.raw *.erofs *.efi; do
        if [[ $f == *.test.raw ]]; then
            # Skip test images
            continue
        fi
        mv "$f" upload-tree/
    done
fi

go -C ./token-redeemer/ run .
go -C ./uploader/ run . --remote "s3+https://storage.kde.org/ci-artifacts/$CI_PROJECT_PATH/j/$CI_JOB_ID"

echo "𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏"
echo "You can find the raw disk images at:"
echo "https://qoomon.github.io/aws-s3-bucket-browser/index.html?bucket=https://storage.kde.org/ci-artifacts/#$CI_PROJECT_PATH/j/$CI_JOB_ID/"
echo "𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏"
