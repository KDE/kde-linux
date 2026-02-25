#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

set -eux

OUTDIR=mkosi.output

# For the vacuum helper and this script
export SSH_IDENTITY="$PWD/.secure_files/ssh.key"
export SSH_USER=kdeos
export SSH_HOST=origin.files.kde.org
export SSH_ROOT_PATH=/home/kdeos/kde-linux/
export SSH_PATH=$SSH_ROOT_PATH/sysupdate/v2/
export SSH_REALLY_DELETE=1

chmod 600 "$SSH_IDENTITY"

go -C ./upload-vacuum/ build -o upload-vacuum .
./upload-vacuum/upload-vacuum

# The following variables are for this script only. Not shared with the vacuum helper.
sudo chown -Rvf "$(id -u):$(id -g)" "$PWD/.secure_files" # Make sure we have access
export GNUPGHOME="$PWD/.secure_files/gpg"
gpg --verbose --no-options --homedir="$GNUPGHOME" --import "$PWD/.secure_files/gpg.private.key"
REMOTE_ROOT=$SSH_USER@$SSH_HOST:$SSH_ROOT_PATH
REMOTE_PATH=$SSH_USER@$SSH_HOST:$SSH_PATH
# You can use `ssh-keyscan origin.files.kde.org` to get the host key
echo "origin.files.kde.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUjdH4S7otYIdLUkOZK+owIiByjNQPzGi7GQ5HOWjO6" >> ~/.ssh/known_hosts

# The initial SHA256SUMS file is created by the vacuum script based on what is left on the server. We append to it.

sudo chown -R "$USER":"$USER" "$OUTDIR"
cd "$OUTDIR"

# We need shell globs here! More readable this way. Ignore shellcheck.
# shellcheck disable=SC2129
sha256sum -- *.efi >> SHA256SUMS
sha256sum -- *.tar.zst >> SHA256SUMS
sha256sum -- *.erofs >> SHA256SUMS
# Don't put .erofs.caibx into the SHA256SUMS, it will break file matching.
# https://github.com/systemd/systemd/issues/38605
sha256sum -- *-x86-64.caibx >> SHA256SUMS

gpg --homedir="$GNUPGHOME" --output SHA256SUMS.gpg --detach-sign SHA256SUMS

scp -i "$SSH_IDENTITY" ./*.raw ./*.torrent "$REMOTE_ROOT"
scp -i "$SSH_IDENTITY" ./*.efi ./*.tar.zst ./*.erofs ./*.caibx "$REMOTE_PATH"
scp -i "$SSH_IDENTITY" SHA256SUMS SHA256SUMS.gpg "$REMOTE_PATH" # upload as last artifact to finalize the upload

# The new s3 based upload system

S3_STORE="s3+https://storage.kde.org/kde-linux/sysupdate/store/"
S3_TARGET="s3+https://storage.kde.org/kde-linux/testing/"

## Upload to the chunk store directly
go install -v github.com/folbricht/desync/cmd/desync@latest
go -C ./token-redeemer/ run .
~/go/bin/desync chop \
    --concurrency "$(nproc)" \
    --store "$S3_STORE" \
    ./*-x86-64.caibx \
    ./*-x86-64.erofs

## Prepare the image upload tree
cd ..
rm -rf upload-tree
mkdir -p upload-tree/sysupdate/v2

mv "$OUTDIR"/*.raw "$OUTDIR"/*.torrent upload-tree/
mv "$OUTDIR"/*.efi "$OUTDIR"/*.tar.zst "$OUTDIR"/*.erofs "$OUTDIR"/*.caibx "$OUTDIR"/SHA256SUMS "$OUTDIR"/SHA256SUMS.gpg upload-tree/sysupdate/v2/

### Upload
go -C ./token-redeemer/ run .
go -C ./uploader/ run . --remote "$S3_TARGET"
