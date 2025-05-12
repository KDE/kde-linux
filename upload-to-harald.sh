#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

set -eux

chmod 600 .upload-to-harald.key
[ -d ~/.ssh ] || mkdir ~/.ssh
chmod 700 ~/.ssh
echo "[images.kde-linux.haraldsitter.eu]:2022 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYrQxa50Ko0lkUz69Fq6JTcADy8jtdFZy8EUbo3/U6F" >> ~/.ssh/known_hosts
chmod 600 ~/.ssh/known_hosts

echo "cd images" > upload-to-harald.sftp
for f in *.raw *.erofs *.efi; do
    if [[ $f == *.test.raw ]]; then
        # Skip test images
        continue
    fi
    echo "put $f" >> upload-to-harald.sftp
done
sftp -4 -b upload-to-harald.sftp -P 2022 -i .upload-to-harald.key upload@images.kde-linux.haraldsitter.eu
