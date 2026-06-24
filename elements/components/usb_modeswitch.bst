# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/usb_modeswitch/-/raw/main/PKGBUILD?ref_type=heads
kind: make

description: Activating switchable USB devices on Linux.

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/pkg-config.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libusb.bst

variables:
  make-install: |
    make DESTDIR="%{install-root}" UDEVDIR="%{install-root}%{prefix}/lib/udev" install
    install -Dm755 "%{install-root}%{prefix}/sbin/usb_modeswitch" "%{install-root}%{bindir}/usb_modeswitch"
    install -Dm755 "%{install-root}%{prefix}/sbin/usb_modeswitch_dispatcher" "%{install-root}%{bindir}/usb_modeswitch_dispatcher"
    rm -rf "%{install-root}%{prefix}/sbin"
    sed -i 's|/usr/sbin/usb_modeswitch|%{bindir}/usb_modeswitch|g' "%{install-root}%{prefix}/lib/udev/usb_modeswitch"

sources:
- kind: tar
  url: http://www.draisberghof.de/usb_modeswitch/usb-modeswitch-2.6.2.tar.bz2
  ref: f7abd337784a9d1bd39cb8a587518aff6f2a43d916145eafd80b1b8b7146db66
