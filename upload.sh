#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024-2025 Harald Sitter <sitter@kde.org>

set -eux

# export VACUUM_REALLY_DELETE=1 # <<<<<<<<<<<<<<<<<<<<<<<<<<<<< be careful with this!
go -C ./upload-vacuum/ run .

# The following variables are for this script only. Not shared with the vacuum helper.
sudo chown -Rvf "$(id -u):$(id -g)" "$PWD/.secure_files" # Make sure we have access
export GNUPGHOME="$PWD/.secure_files/gpg"
gpg --verbose --no-options --homedir="$GNUPGHOME" --import "$PWD/.secure_files/gpg.private.key"

# Image files
mv ./*.raw upload-tree/
mv ./*.torrent upload-tree/
# Update files
mv ./*.efi upload-tree/sysupdate/v3/
mv ./*.tar.zst upload-tree/sysupdate/v3/
mv ./*.erofs upload-tree/sysupdate/v3/
mv ./*.caibx upload-tree/sysupdate/v3/

pushd upload-tree/sysupdate/v3/
# The initial SHA256SUMS file is created by the vacuum script based on what is left on the server. We append to it.
# We split this across multiple lines for ease of reading. Ignore shellcheck.
# shellcheck disable=SC2129
sha256sum -- *.efi >> SHA256SUMS
sha256sum -- *.tar.zst >> SHA256SUMS
sha256sum -- *.erofs >> SHA256SUMS
# Don't put .erofs.caibx into the SHA256SUMS, it will break file matching.
# https://github.com/systemd/systemd/issues/38605
sha256sum -- *-x86-64.caibx >> SHA256SUMS
popd

pushd upload-tree/sysupdate/v3
gpg --homedir="$GNUPGHOME" --output SHA256SUMS.gpg --detach-sign SHA256SUMS
popd

~/go/bin/desync chop \
    --store upload-tree/sysupdate/store \
    upload-tree/sysupdate/v3/*.erofs.caibx \
    upload-tree/sysupdate/v3/*.erofs
go -C ./uploader/ run .
