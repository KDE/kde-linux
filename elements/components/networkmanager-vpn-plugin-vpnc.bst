# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/networkmanager-vpnc/-/raw/main/PKGBUILD?ref_type=heads
description: NetworkManager VPN plugin for VPNC

kind: autotools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- gnome-build-meta.bst:core-deps/intltool.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/gtk3.bst
- freedesktop-sdk.bst:components/networkmanager.bst
- components/libnma.bst

sources:
- kind: git_repo
  url: https://gitlab.gnome.org/GNOME/NetworkManager-vpnc.git
  track: '*'
  ref: 1.4.1-dev-0-g2c7a5e161f6fd169b2afc7af04122c288ce3ee8e
