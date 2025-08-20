#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>

set -eux

# For the vacuum helper and this script
export SSH_IDENTITY="$PWD/.secure_files/ssh.key"
export SSH_USER=kdeos
export SSH_HOST=origin.files.kde.org
export SSH_PATH=/home/kdeos/kde-linux
export SSH_REALLY_DELETE=1

chmod 600 "$SSH_IDENTITY"

go -C ./upload-vacuum/ build -o upload-vacuum .
./upload-vacuum/upload-vacuum

# The following variables are for this script only. Not shared with the vacuum helper.
sudo chown -Rvf "$(id -u):$(id -g)" "$PWD/.secure_files" # Make sure we have access
export GNUPGHOME="$PWD/.secure_files/gpg"
gpg --verbose --no-options --homedir="$GNUPGHOME" --import "$PWD/.secure_files/gpg.private.key"
REMOTE=$SSH_USER@$SSH_HOST:$SSH_PATH
# You can use `ssh-keyscan origin.files.kde.org` to get the host key
echo "origin.files.kde.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUjdH4S7otYIdLUkOZK+owIiByjNQPzGi7GQ5HOWjO6" >> ~/.ssh/known_hosts

# The initial SHA256SUMS file is created by the vacuum script based on what is left on the server. We append to it.

sysupdate_dir=sysupdate/v2
mkdir -p "$sysupdate_dir"
mv ./*.efi ./*.tar.zst ./*.erofs ./*.caibx "$sysupdate_dir"

# We need shell globs here! More readable this way. Ignore shellcheck.
# shellcheck disable=SC2129
sha256sum -- *.raw >> SHA256SUMS
sha256sum -- *.torrent >> SHA256SUMS
sha256sum -- ${sysupdate_dir}/*.efi >> SHA256SUMS
sha256sum -- ${sysupdate_dir}/*.tar.zst >> SHA256SUMS
sha256sum -- ${sysupdate_dir}/*.erofs >> SHA256SUMS
# Don't put caibx into the SHA256SUMS, it will break file matching.
# https://github.com/systemd/systemd/issues/38605

gpg --homedir="$GNUPGHOME" --output SHA256SUMS.gpg --detach-sign SHA256SUMS

scp -i "$SSH_IDENTITY" ./*.raw ./*.torrent "$REMOTE"
scp -r -i "$SSH_IDENTITY" "sysupdate/" "$REMOTE"
scp -i "$SSH_IDENTITY" SHA256SUMS SHA256SUMS.gpg "$REMOTE" # upload as last artifact to finalize the upload
