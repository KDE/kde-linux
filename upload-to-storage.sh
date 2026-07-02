#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025-2026 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

set -eux

# Output Directory
OUTDIR="${OUTDIR:-mkosi.output}"

# We need to wire up an ephemeral image-signing key pair for OpenQA. We can't use the production key, but we still need
# to test if the image can be upgraded to. Hence, create a key pair and pass it into OpenQA, where it will be injected
# into the system.
GNUPGHOME="$PWD/.openqa-gpg"
rm -rf "$GNUPGHOME"
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"
gpg --batch --pinentry-mode loopback --homedir="$GNUPGHOME" --passphrase "" --quick-generate-key "KDE Linux openQA <linux@kde.org>" ed25519 sign 3d
SYSUPDATE_PUBKEY_B64=$(gpg --homedir="$GNUPGHOME" --export --armor "KDE Linux openQA <linux@kde.org>" | base64 -w0)

mv upload-tree upload-tree-old || true
if [ ! -d upload-tree ]; then
    mkdir -p upload-tree/sysupdate/v2
    mv "$OUTDIR"/*.iso upload-tree/
    mv "$OUTDIR"/*.efi "$OUTDIR"/*.tar.zst "$OUTDIR"/*.erofs "$OUTDIR"/*.caibx upload-tree/sysupdate/v2/
    (
        cd upload-tree/sysupdate/v2
        # shellcheck disable=SC2129
        sha256sum -- *.efi >> SHA256SUMS
        sha256sum -- *.tar.zst >> SHA256SUMS
        sha256sum -- *.erofs >> SHA256SUMS
        # Don't put .erofs.caibx into SHA256SUMS, it will break file matching.
        # https://github.com/systemd/systemd/issues/38605
        sha256sum -- *-x86-64.caibx >> SHA256SUMS

        # Sign, so test images can actually verify and upgrade from artifacts.
        gpg --homedir="$GNUPGHOME" --output SHA256SUMS.gpg --detach-sign SHA256SUMS
    )
fi

go -C ./token-redeemer/ run .
go -C ./uploader/ run . --remote "s3+https://storage.kde.org/ci-artifacts/$CI_PROJECT_PATH/j/$CI_JOB_ID"

# Point OpenQA at the image we just uploaded.
ISO_FILE=$(find upload-tree -maxdepth 1 -name '*.iso' | head -1 | xargs -r basename)
echo "IMAGE_URL=https://storage.kde.org/ci-artifacts/$CI_PROJECT_PATH/j/$CI_JOB_ID/$ISO_FILE" >> build.env
echo "STAGING_CHANNEL_URL=https://storage.kde.org/ci-artifacts/$CI_PROJECT_PATH/j/$CI_JOB_ID/sysupdate/v2/" >> build.env
echo "SYSUPDATE_PUBKEY_B64=$SYSUPDATE_PUBKEY_B64" >> build.env

echo "𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏"
echo "You can find the raw disk images and sysupdate tree at:"
echo "https://qoomon.github.io/aws-s3-bucket-browser/index.html?bucket=https://storage.kde.org/ci-artifacts/#$CI_PROJECT_PATH/j/$CI_JOB_ID/"
echo "𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏𓃀𓂝𓏏"
