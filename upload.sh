#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>

set -eu

# For the vacuum helper and this script
export SSH_IDENTITY="$PWD/.secure_files/ssh.key"
export SSH_USER=kdeos
export SSH_HOST=origin.files.kde.org
export SSH_PATH=/home/kdeos/kde-linux
export SSH_REALLY_DELETE=1

chmod 600 "$SSH_IDENTITY"

go -C ./upload-vacuum/ build -o upload-vacuum .
cd mkosi.output
../upload-vacuum/upload-vacuum

# For this script only
export GNUPGHOME="$PWD/../.secure_files/gpg"
gpg --no-options --homedir="$GNUPGHOME" --import "$PWD/../.secure_files/gpg.private.key"
REMOTE=$SSH_USER@$SSH_HOST:$SSH_PATH
# You can use `ssh-keyscan origin.files.kde.org` to get the host key
echo "origin.files.kde.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUjdH4S7otYIdLUkOZK+owIiByjNQPzGi7GQ5HOWjO6" >> ~/.ssh/known_hosts

# The initial SHA256SUMS file is created by the vacuum script based on what is left on the server. We append to it.

# More readable this way, ignore shellcheck
# shellcheck disable=SC2129
sha256sum -- *.efi >> SHA256SUMS
sha256sum -- *.raw >> SHA256SUMS
sha256sum -- *.tar.zst >> SHA256SUMS
sha256sum -- *.torrent >> SHA256SUMS

gpg --homedir="$GNUPGHOME" --output SHA256SUMS.gpg --detach-sign SHA256SUMS

scp -i "$SSH_IDENTITY" ./*.efi ./*.raw ./*.tar.zst ./*.torrent "$REMOTE"
scp -i "$SSH_IDENTITY" SHA256SUMS SHA256SUMS.gpg "$REMOTE" # upload as last artifact to finalize the upload
