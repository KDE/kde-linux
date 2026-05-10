#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
# Bootstraps a Fedora Docker container to be ready for building KDE Linux.
# WARNING: DO NOT CALL INTO OTHER SCRIPTS HERE.
# This file needs to be self-contained because it gets run by the CI VM provisioning in isolation.
# Exit immediately if any command fails and print all commands before they are executed.
set -ex

# Pin to the same Koji compose used by the packages pipeline so the base OS
# and KDE packages don't go out of sync.
# TODO: Once the packages pipeline publishes compose_id.txt to storage.kde.org,
# fetch it from there instead.
COMPOSE_ID=$(curl -sf https://storage.kde.org/kde-linux-packages/testing/repo/compose_id.txt || \
             curl -sf https://kojipkgs.fedoraproject.org/compose/rawhide/latest-Fedora-Rawhide/COMPOSE_ID || true)

if [ -n "$COMPOSE_ID" ]; then
    dnf config-manager setopt "*.baseurl=https://kojipkgs.fedoraproject.org/compose/rawhide/${COMPOSE_ID}/compose/Everything/x86_64/os/"
    dnf config-manager setopt "*.metalink="
    dnf config-manager setopt "*.mirrorlist="
else
    echo "WARNING: Could not fetch compose ID, using default Fedora Rawhide repos"
fi

dnf distro-sync -y

dnf install -y \
    mkosi \
    systemd \
    btrfs-progs \
    clang \
    compsize \
    cpio \
    dosfstools \
    duperemove \
    erofs-utils \
    flatpak \
    git \
    golang \
    openssh-clients \
    qemu-system-x86 \
    qemu-img \
    rsync \
    ruby \
    rubygem-nokogiri \
    rust \
    cargo \
    squashfs-tools \
    transmission-cli \
    tree \
    systemd-ukify \
    wget \
    arch-install-scripts  # TODO: not available on Fedora, find alternative
