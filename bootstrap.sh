#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>

# Bootstraps an Arch Linux Docker container to be ready for building KDE Linux.

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

# Restore the pacman.conf file from the pacman package. The docker one is crippled with NoExtract options and the like :(
mkdir /tmp/pacman
pacman --sync --refresh --downloadonly --noconfirm pacman
tar --extract --file "$(find /var/cache/pacman/pkg -name 'pacman-*.pkg.tar.zst')" --directory /tmp/pacman
cp /tmp/pacman/etc/pacman.conf /etc/pacman.conf

cat <<- EOF >> /etc/pacman.conf
[kde-linux]
# Signature checking is not needed because the packages are served over HTTPS and we have no mirrors
SigLevel = Never
Server = https://cdn.kde.org/kde-linux/packaging/packages/

[kde-linux-debug]
SigLevel = Never
Server = https://cdn.kde.org/kde-linux/packaging/packages-debug/
EOF

cp /etc/pacman.conf mkosi.sandbox/etc

if [ ! -f mkosi.sandbox/etc/pacman.d/mirrorlist ]; then
  # Insert a fallback for starters
  # shellcheck disable=SC2016
  echo 'Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
  # Then use fastest servers we can find
  pacman --sync --refresh --noconfirm reflector
  reflector --protocol https --country ${MIRRORS_COUNTRY:-de} --score 10 --fastest 3 >mkosi.sandbox/etc/pacman.d/mirrorlist
fi
PARALLEL_DOWNLOADS=${PARALLEL_DOWNLOADS:-5}
cp mkosi.sandbox/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist

# enable parallel downloads for m0ar speed!
sed -i 's/#*\(ParallelDownloads =\) .*/\1 '"${PARALLEL_DOWNLOADS}"'/' mkosi.sandbox/etc/pacman.conf

# Update the system and install packages we'll need for building KDE Linux.
# Even though we use mkosi from Git, we'll grab the package,
# to make sure all the dependencies are properly pulled.
pacman --sync --refresh --noconfirm --sysupgrade \
    mkosi \
    arch-install-scripts \
    base-devel \
    btrfs-progs \
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
    squashfs-tools \
    transmission-cli \
    tree \
    ukify

# Use mkosi from Git so we don't have to wait for releases when things break.
# OTOH, things may break in Git. Therefore, which version is used may change over time.
git clone https://github.com/systemd/mkosi.git /tmp/mkosi
ln --symbolic /tmp/mkosi/bin/mkosi /usr/local/bin/mkosi
