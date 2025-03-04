#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2023-2024 Harald Sitter <sitter@kde.org>

set -ex

#rm -vf ./*.addon.efi
#rm -rfv /efi/EFI/Linux/kde-linux_*.efi.extra.d

if [ "$@" != "" ]; then
  # any argument de-addons
  exit 0
fi

ukify build \
  --cmdline 'console=ttyS0 console=tty0
    rd.systemd.debug_shell=on systemd.debug_shell=on SYSTEMD_SULOGIN_FORCE=1
    systemd.log_level=debug systemd.log_target=kmsg log_buf_len=1M printk.devkmsg=on' \
  --output debug.addon.efi

ukify build \
  --cmdline 'init=/usr/lib/systemd/systemd-bootchart' \
  --output bootchart.addon.efi

efis=(/efi/EFI/Linux/kde-linux_*.efi)
efi=${efis[-1]}
name=$(basename "$efi")
mkdir "/efi/EFI/Linux/$name.extra.d"
cp -v ./*.addon.efi "/efi/EFI/Linux/$name.extra.d"
