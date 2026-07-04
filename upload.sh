#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

set -eux

if [[ -z "${1:-}" ]]; then
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

if [[ "$STAGE" -eq 1 && "$PUBLISH" -eq 1 ]] || [[ "$STAGE" -ne 1 && "$PUBLISH" -ne 1 ]]; then
    echo "Must choose exactly one of --stage or --publish."
    exit 1
fi

OUTDIR=mkosi.output

# For the vacuum helper and this script
export SSH_IDENTITY="$PWD/.secure_files/ssh.key"
export SSH_USER=kdeos
export SSH_HOST=tinami.kde.org
export SSH_ROOT_PATH=/srv/archives/files/kde-linux
export SSH_SYSUPDATE_PATH=$SSH_ROOT_PATH/sysupdate/v2/
export SSH_REALLY_DELETE=1
export VACUUM_REALLY_DELETE=1
export GNUPGHOME="$PWD/.secure_files/gpg"

# upload tree built during staging
V2_TREE="upload-tree/sysupdate/v2"
S3_TARGET="s3+https://storage.kde.org/kde-linux/"
S3_CHANNEL_TARGET="${S3_TARGET}testing/"
S3_STORE="${S3_TARGET}sysupdate/store/"

# files.kde.org scp targets. We don't stage on files.kde.org, only on the storage.kde.org bucket.
# We download from the bucket then upload directly to files.kde.org to publish there.
REMOTE_ROOT_PATH=$SSH_USER@$SSH_HOST:$SSH_ROOT_PATH
REMOTE_SYSUPDATE_PATH=$SSH_USER@$SSH_HOST:$SSH_SYSUPDATE_PATH
# You can use `ssh-keyscan tinami.kde.org` to get the host key
echo "tinami.kde.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUjdH4S7otYIdLUkOZK+owIiByjNQPzGi7GQ5HOWjO6" >> ~/.ssh/known_hosts

stage() {
    S3_TARGET_STAGING="s3+https://storage.kde.org/kde-linux/staging/$CI_JOB_ID"

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

    # Upload to the per-job staging prefix in the bucket.
    go -C ./token-redeemer/ run .
    go -C ./uploader/ run . --remote "$S3_TARGET_STAGING"

    # Emit the exact staging target for the publish job, plus public URLs for
    # OpenQA to test the staged image and sysupdate channel.
    ISO_FILE=$(find upload-tree -maxdepth 1 -name '*.iso' | head -1 | xargs -r basename)
    echo "S3_TARGET_STAGING=$S3_TARGET_STAGING" >> build.env
    echo "IMAGE_URL=${S3_TARGET_STAGING#s3+}/$ISO_FILE" >> build.env
    echo "STAGING_CHANNEL_URL=${S3_TARGET_STAGING#s3+}/sysupdate/v2/" >> build.env
    echo "SYSUPDATE_PUBKEY_B64=" >> build.env
}

publish() {
    if [[ -z "$S3_TARGET_STAGING" ]]; then
        echo "S3_TARGET_STAGING must be supplied by the imaging job dotenv artifact." >&2
        exit 1
    fi

    # Pull the staged build down from the bucket into ./publish-artifacts.
    rm -rf publish-artifacts
    mkdir -p publish-artifacts
    go -C ./token-redeemer/ run .
    go -C ./publisher/ build -o publisher .
    umask 022
    ./publisher/publisher --src "$S3_TARGET_STAGING" --output publish-artifacts --download
    shopt -s nullglob
    publish_artifacts=(publish-artifacts/*.iso publish-artifacts/*.torrent publish-artifacts/*.efi publish-artifacts/*.tar.zst publish-artifacts/*.erofs publish-artifacts/*.caibx)
    shopt -u nullglob
    if [[ "${#publish_artifacts[@]}" -eq 0 ]]; then
        echo "No staged artifacts found at $S3_TARGET_STAGING; assuming this staging prefix was already published."
        exit 0
    fi

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

        chmod 644 ./*.iso ./*.torrent ./*.efi ./*.tar.zst ./*.erofs ./*.caibx
        scp -i "$SSH_IDENTITY" ./*.iso ./*.torrent "$REMOTE_ROOT_PATH"
        scp -i "$SSH_IDENTITY" ./*.efi ./*.tar.zst ./*.erofs ./*.caibx "$REMOTE_SYSUPDATE_PATH"
    )

    # Push the rootfs chunks into the S3 chunk store.
    go install -v github.com/folbricht/desync/cmd/desync@f67d01e
    export PATH="$HOME/go/bin:$PATH"
    go -C ./token-redeemer/ run .
    desync chop \
        --concurrency "$(nproc)" \
        --store "$S3_STORE" \
        publish-artifacts/*-x86-64.caibx \
        publish-artifacts/*-x86-64.erofs

    # Upload sums to files.kde.org only after the chunk store is ready.
    scp -i "$SSH_IDENTITY" publish-artifacts/SHA256SUMS publish-artifacts/SHA256SUMS.gpg "$REMOTE_SYSUPDATE_PATH"

    # Merge the staged tree into the live S3 tree only after files.kde.org and the chunk store are ready.
    go -C ./token-redeemer/ run .
    ./publisher/publisher --src "$S3_TARGET_STAGING" --dest "$S3_CHANNEL_TARGET"

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
chmod 600 "$SSH_IDENTITY"
if [[ ! -d "$GNUPGHOME" ]]; then
    mkdir "$GNUPGHOME"
    chmod 700 "$GNUPGHOME"
    gpg --verbose --no-options --homedir="$GNUPGHOME" --import "$PWD/.secure_files/gpg.public.key"
fi
gpg --verbose --no-options --homedir="$GNUPGHOME" --import "$PWD/.secure_files/gpg.private.key"


if [[ "${STAGE}" -eq 1 ]]; then
    stage
fi

if [[ "${PUBLISH}" -eq 1 ]]; then
    publish
fi
