# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/networkmanager-openvpn/-/raw/main/PKGBUILD?ref_type=heads
description: NetworkManager VPN plugin for OpenVPN

kind: autotools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/systemd.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/gtk3.bst
- freedesktop-sdk.bst:components/libsecret.bst
- freedesktop-sdk.bst:components/networkmanager.bst
- gnome-build-meta.bst:core-deps/libnma.bst
- components/openvpn.bst

sources:
- kind: git_repo
  url: https://gitlab.gnome.org/GNOME/NetworkManager-openvpn.git
  track: '*.*'
  ref: 1.12.5-0-gd03d6a636866e9be9fbec7977ef377c191fb2988
