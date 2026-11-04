# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 KDE Linux Contributors

# systemd >= 261 is required for systemd-repart --el-torito.
FROM ubuntu:26.10

# Keep container dependencies here; bootstrap.sh provisions the separate Arch CI VM.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bubblewrap build-essential btrfs-progs ca-certificates cargo clang \
        btrfs-compsize cpio curl dosfstools duperemove erofs-utils file flatpak git \
        gnupg golang-go libbtrfsutil-dev libclang-dev libssl-dev lzip mkosi mtools openssh-client \
        pkg-config python3-dev python3-pip python3-venv qemu-system-x86 \
        qemu-utils rsync ruby ruby-nokogiri rustc squashfs-tools sudo \
        systemd-container systemd-repart systemd-ukify transmission-cli \
        tree uidmap util-linux wget xz-utils zstd \
    && rm -rf /var/lib/apt/lists/*

# Use a venv rather than changing Ubuntu's externally managed Python environment.
# System packages supply mkosi dependencies such as cryptography and pefile.
ENV VIRTUAL_ENV=/opt/kde-linux-builder
ENV PATH="/opt/kde-linux-builder/bin:${PATH}"
RUN python3 -m venv --system-site-packages "$VIRTUAL_ENV" \
    && python -m pip install --no-cache-dir \
        'BuildStream>=2.7' buildstream-plugins dulwich tomlkit requests \
        'git+https://github.com/systemd/mkosi.git'

# Fail during image creation if a base-image change drops required ISO support.
RUN systemd-repart --help | grep -q -- --el-torito \
    && bst --version \
    && mkosi --version

WORKDIR /workspace
CMD ["/workspace/in_docker.sh"]
