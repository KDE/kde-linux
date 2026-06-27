# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/networkmanager-l2tp/-/raw/main/PKGBUILD?ref_type=heads
description: NetworkManager VPN plugin for L2TP

kind: autotools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/gtk3.bst
- freedesktop-sdk.bst:components/libsecret.bst
- freedesktop-sdk.bst:components/networkmanager.bst
- freedesktop-sdk.bst:components/nspr.bst
- freedesktop-sdk.bst:components/nss.bst
- freedesktop-sdk.bst:components/openssl.bst
- gnome-build-meta.bst:core-deps/ppp.bst
- gnome-build-meta.bst:core-deps/libnma.bst

config:
  configure-commands:
  - autoreconf -fvi
  - >-
    ./configure
    --prefix="%{prefix}"
    --sysconfdir="%{sysconfdir}"
    --localstatedir="%{localstatedir}"
    --libexecdir="%{libexecdir}"
    --disable-static
    --without-gtk4
  install-commands:
  - make DESTDIR="%{install-root}" install dbusservicedir="%{datadir}/dbus-1/system.d"

sources:
- kind: git_repo
  url: github:nm-l2tp/NetworkManager-l2tp
  track: '*'
  ref: 1.52.2-0-g21894a5ddca14b6d91f4fbd736c91d77d1f5bc7a
