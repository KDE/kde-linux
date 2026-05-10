#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025-2026 Vishal Rao <vishalrao@gmail.com>

check() {
    return 0
}

depends() {
    echo systemd
}

install() {
    inst_lib /usr/lib64/libblkid.so
    inst_lib /usr/lib64/libmount.so
}
