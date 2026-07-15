#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>

# Bootstraps an Arch Linux Docker container to be ready for building KDE Linux.

# WARNING: DO NOT CALL INTO OTHER SCRIPTS HERE.
# This file needs to be self-contained because it gets run by the CI VM provisioning in isolation.

# Exit immediately if any command fails and print all commands before they are executed.
set -ex

# From https://hub.docker.com/_/archlinux/:
#
# "For Security Reasons, these images strip the pacman lsign key.
# This is because the same key would be spread to all containers of the same image,
# allowing for malicious actors to inject packages (via, for example, a man-in-the-middle).
# In order to create a lsign-key run pacman-key --init on the first execution,
# but be careful to not redistribute that key."
#
pacman-key --init
# On VM images make sure we have the keyring populated.
pacman-key --populate

# Restore the pacman.conf file from the pacman package. The docker one is crippled with NoExtract options and the like :(
#  --refresh twice to force a refresh
mkdir /tmp/pacman
pacman --sync --refresh --refresh --downloadonly --noconfirm pacman
tar --extract --file "$(ls -v /var/cache/pacman/pkg/pacman-[0-9]*.pkg.tar.zst | tail -n 1)" --directory /tmp/pacman
cp /tmp/pacman/etc/pacman.conf /etc/pacman.conf

cp /etc/pacman.conf /etc/pacman.conf.nolinux # store a backup for use in the packages pipeline

# Ensure the packages repo and the base image do not go out of sync
# by using the same snapshot date from BUILD_REPO.txt for both
# WARNING: code copy in build.sh
BUILD_REPO=$(curl --fail --silent https://storage.kde.org/kde-linux-packages/testing/repo/build_repo.txt)
if [ -z "$BUILD_REPO" ]; then
  echo "ERROR: Could not fetch build_repo.txt — refusing to build out-of-sync image." >&2
  exit 1
fi
echo "Server = ${BUILD_REPO}/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

# ParallelDownloads is enabled by default since pacman 7.0.0.r6.gc685ae6-2,
# so no need to uncomment or manually set it unless we want to change the value.

# Update the system and install packages we'll need for building KDE Linux.
#  --refresh twice to force a refresh
pacman --sync --refresh --refresh --noconfirm --sysupgrade \
    mkosi \
    arch-install-scripts \
    base-devel \
    btrfs-progs \
    clang \
    compsize \
    cpio \
    dosfstools \
    duperemove \
    erofs-utils \
    flatpak \
    git \
    go \
    openssh \
    qemu-base \
    qemu-img \
    rsync \
    ruby \
    ruby-nokogiri \
    rust \
    squashfs-tools \
    transmission-cli \
    tree \
    ukify \
    wget \
    lzip \
    python-pip

pip install --break-system-packages 'BuildStream>=2.7' buildstream-plugins dulwich tomlkit
