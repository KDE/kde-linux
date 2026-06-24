# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/linux-tools/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

build-depends:
- freedesktop-sdk.bst:components/gettext.bst
- freedesktop-sdk.bst:components/which.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
- freedesktop-sdk.bst:components/pciutils.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  build-commands:
  - make -C tools/power/cpupower VERSION=7.1.1-1
  install-commands:
  - >-
    make -C tools/power/cpupower
    DESTDIR="%{install-root}"
    confdir="/etc/default/"
    sbindir="%{bindir}"
    libdir="%{libdir}"
    libexecdir="%{libexecdir}/systemd/scripts"
    mandir="%{mandir}"
    docdir="%{datadir}/doc/cpupower"
    install install-man

sources:
- kind: tar
  url: https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.1.1.tar.xz
  ref: 5215fa3541dc7e7f5bcd51bf7e57f169cec6fce508ca54e3dc85fdee14371d7d
- kind: remote
  url: https://gitlab.archlinux.org/archlinux/packaging/packages/linux-tools/-/raw/main/usbipd.service?ref_type=heads
  ref: 2e187734d8aec58a3046d79883510d779aa93fb3ab20bd3132c1a607ebe5498f
- kind: remote
  url: https://gitlab.archlinux.org/archlinux/packaging/packages/linux-tools/-/raw/main/hv_kvp_daemon.service?ref_type=heads
  ref: b1315cb77a35454e1af9172f821a52e2a0cb18561be05a340d21cf337b01ae61
- kind: remote
  url: https://gitlab.archlinux.org/archlinux/packaging/packages/linux-tools/-/raw/main/hv_vss_daemon.service?ref_type=heads
  ref: 2d5e2f8d40b6f19bf2e1dead57ca105d72098fb0b418c09ff2e0cb91089710af
