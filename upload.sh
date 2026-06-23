#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

set -eux

if [[ -z "$1" ]]; then
    echo "Choice between --stage and --publish must be provided as argument." >&2
    exit 1
fi

STAGE=
PUBLISH=
while [[ $# -gt 0 ]]; do
    case "$1" in
        --stage)
            STAGE=1
            shift
            ;;
        --publish)
            PUBLISH=1
            shift
            ;;
        *)
            echo "Unknown option $1."
            exit 1
            ;;
    esac
done

OUTDIR=mkosi.output

# For the vacuum helper and this script
export SSH_IDENTITY="$PWD/.secure_files/ssh.key"
export SSH_USER=kdeos
export SSH_HOST=origin.files.kde.org
export SSH_ROOT_PATH=/home/kdeos/kde-linux/
export SSH_PATH=$SSH_ROOT_PATH/sysupdate/v2/
export SSH_REALLY_DELETE=1
export VACUUM_REALLY_DELETE=1
export GNUPGHOME="$PWD/.secure_files/gpg"

chmod 600 "$SSH_IDENTITY"

# The following variables are for this script only. Not shared with the vacuum helper.
STAGING_DIR="staging/${CI_PIPELINE_ID}"

# upload tree built during staging
V2_TREE="upload-tree/sysupdate/v2"

S3_TARGET="s3+https://storage.kde.org/kde-linux/"
S3_STORE="${S3_TARGET}sysupdate/store/"
S3_TARGET_STAGING="${S3_TARGET}testing/${STAGING_DIR}"

# files.kde.org scp targets. We don't stage on files.kde.org, only on the storage.kde.org bucket.
# We download from the bucket then upload directly to files.kde.org to publish there.
REMOTE_ROOT=$SSH_USER@$SSH_HOST:$SSH_ROOT_PATH
REMOTE_PATH=$SSH_USER@$SSH_HOST:$SSH_PATH
# You can use `ssh-keyscan origin.files.kde.org` to get the host key
echo "origin.files.kde.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUjdH4S7otYIdLUkOZK+owIiByjNQPzGi7GQ5HOWjO6" >> ~/.ssh/known_hosts

stage() {
    # Stage the freshly built image into the bucket.
    sudo chown -R "$USER":"$USER" "$OUTDIR"

    (
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
    )

    # Prepare the staging upload tree.
    rm -rf upload-tree
    mkdir -p "$V2_TREE"
    mv "$OUTDIR"/*.iso "$OUTDIR"/*.torrent upload-tree/
    mv "$OUTDIR"/*.efi "$OUTDIR"/*.tar.zst "$OUTDIR"/*.erofs "$OUTDIR"/*.caibx "$V2_TREE/"
    mv "$OUTDIR"/SHA256SUMS "$OUTDIR"/SHA256SUMS.gpg "$V2_TREE/"

    # Upload to the per-pipeline staging prefix in the bucket.
    go -C ./token-redeemer/ run .
    go -C ./uploader/ run . --remote "$S3_TARGET_STAGING"

    # Emit the public URL of the staged image for the OpenQA CI stage.
    echo "IMAGE_URL=${S3_TARGET_STAGING#s3+}/$(basename upload-tree/*.iso)" >> build.env
}

publish() {
    # Pull the staged build down from the bucket into ./publish-artifacts, then
    # merge the staging tree into the live tree on S3.
    rm -rf publish-artifacts
    mkdir -p publish-artifacts
    go -C ./token-redeemer/ run .
    go -C ./publisher/ build -o publisher .
    ./publisher/publisher --remote "$S3_TARGET_STAGING" --output publish-artifacts

    # Publish to files.kde.org.
    go -C ./upload-vacuum/ build -o upload-vacuum .
    (
        cd publish-artifacts
        ../upload-vacuum/upload-vacuum

        # shellcheck disable=SC2129
        sha256sum -- *.efi >> SHA256SUMS
        sha256sum -- *.tar.zst >> SHA256SUMS
        sha256sum -- *.erofs >> SHA256SUMS
        # https://github.com/systemd/systemd/issues/38605
        sha256sum -- *-x86-64.caibx >> SHA256SUMS

        gpg --homedir="$GNUPGHOME" --output SHA256SUMS.gpg --detach-sign SHA256SUMS

        scp -i "$SSH_IDENTITY" ./*.iso ./*.torrent "$REMOTE_ROOT"
        scp -i "$SSH_IDENTITY" ./*.efi ./*.tar.zst ./*.erofs ./*.caibx "$REMOTE_PATH"
        scp -i "$SSH_IDENTITY" SHA256SUMS SHA256SUMS.gpg "$REMOTE_PATH" # last, to finalize the upload
    )

    # Push the rootfs chunks into the S3 chunk store.
    go install -v github.com/folbricht/desync/cmd/desync@latest
    export PATH="$HOME/go/bin:$PATH"
    go -C ./token-redeemer/ run .
    desync chop \
        --concurrency "$(nproc)" \
        --store "$S3_STORE" \
        publish-artifacts/*-x86-64.caibx \
        publish-artifacts/*-x86-64.erofs

    # Regenerate, re-sign and re-upload SHA256SUMS.
    go -C ./token-redeemer/ run .
    go -C ./upload-vacuum-v3/ run .

    gpg --homedir="$GNUPGHOME" \
        --output "upload-tree/testing/sysupdate/v2/SHA256SUMS.gpg" \
        --detach-sign "upload-tree/testing/sysupdate/v2/SHA256SUMS"
    go -C ./token-redeemer/ run .
    go -C ./uploader/ run . --remote "$S3_TARGET"
}

sudo chown -Rvf "$(id -u):$(id -g)" "$PWD/.secure_files" # Make sure we have access
gpg --verbose --no-options --homedir="$GNUPGHOME" --import "$PWD/.secure_files/gpg.private.key"


if [[ "${STAGE}" -eq 1 ]]; then
    stage
fi

if [[ "${PUBLISH}" -eq 1 ]]; then
    publish
fi
