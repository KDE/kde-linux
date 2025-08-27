#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2023-2024 Harald Sitter <sitter@kde.org>

set -ex

# -----------------------------------------------------------------------------
# Validate tmpfiles.d symlinks against factory defaults
# -----------------------------------------------------------------------------
grep -h '^L[[:space:]]' /usr/lib/tmpfiles.d/*.conf | grep -v '^L[?+]' | \
while read -r type path _ _ _ target; do
    # Remove quotes if present and extract the actual target path
    target=$(echo "$target" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
    
    # Check if target is empty (defaults to factory location)
    if [ -z "$target" ] || [ "$target" = "-" ]; then
        # Extract filename from path to determine factory location
        filename=$(basename "$path")
        if [ "$filename" = "etc" ] || echo "$path" | grep -q '^/etc/'; then
            factory_target="/usr/share/factory/etc/${path#/etc/}"
        elif [ "$filename" = "var" ] || echo "$path" | grep -q '^/var/'; then
            factory_target="/usr/share/factory/var/${path#/var/}"
        else
            factory_target="/usr/share/factory$path"
        fi
        echo "L $path -> (factory default: $factory_target)"
        if [ -e "$factory_target" ]; then
            echo "  ✓ Factory target exists: $factory_target"
        else
            echo "  ✗ Factory target missing: $factory_target"
            exit 1
        fi
    else
        echo "L $path -> $target"
        if [ -e "$target" ]; then
            echo "  ✓ Target exists: $target"
        else
            echo "  ✗ Target missing: $target"
            exit 1
        fi
    fi
done
# -----------------------------------------------------------------------------

rm -vf ./*.addon.efi
rm -rfv /efi/EFI/Linux/kde-linux_*.efi.extra.d

if [ "$@" != "" ]; then
  # any argument de-addons
  exit 0
fi

ukify build \
  --cmdline 'console=ttyS0 console=tty0
    rd.systemd.debug_shell=on systemd.debug_shell=on SYSTEMD_SULOGIN_FORCE=1
    systemd.log_level=debug systemd.log_target=kmsg log_buf_len=1M printk.devkmsg=on systemd.show_status=auto rd.udev.log_level=3' \
  --output debug.addon.efi

ukify build \
  --cmdline 'init=/usr/lib/systemd/systemd-bootchart' \
  --output bootchart.addon.efi

efis=(/efi/EFI/Linux/kde-linux_*.efi)
efi=\${efis[-1]}
name=\$(basename "\$efi")
mkdir "/efi/EFI/Linux/\$name.extra.d"
cp -v ./*.addon.efi "/efi/EFI/Linux/\$name.extra.d"
