#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2023-2024 Harald Sitter <sitter@kde.org>

check() {
    return 0
}

depends() {
    echo systemd udev
}

install() {
    inst_binary /usr/lib/systemd/systemd-volatile-root
    inst_binary /usr/lib/rootfs-transition
    inst_binary /usr/lib/btrfs-migrator
    inst_binary /usr/lib/systemd/system-generators/00-kde-linux-os-release
    inst_binary /usr/lib/systemd/system-generators/kde-linux-live-generator
    inst_binary /usr/lib/systemd/system-generators/kde-linux-mount-generator
    inst_binary /usr/lib/systemd/systemd-bootchart
    inst_binary /usr/lib/etc-factory
    inst_binary /usr/bin/btrfs

    inst_simple /usr/lib/systemd/system/systemd-volatile-root.service
    inst_simple /usr/lib/systemd/system/systemd-bootchart.service
    inst_simple /usr/lib/systemd/system/etc-factory.service

    inst_rules 90-image-dissect.rules
}
