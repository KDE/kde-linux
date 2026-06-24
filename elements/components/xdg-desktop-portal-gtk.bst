# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/xdg-desktop-portal-gtk/-/raw/main/PKGBUILD?ref_type=heads
kind: meson

description: A backend implementation for xdg-desktop-portal using GTK

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/xdg-desktop-portal.bst

variables:
  meson-local: >-
    -Dwallpaper=disabled

sources:
- kind: git_repo
  url: github:flatpak/xdg-desktop-portal-gtk
  track: '*'
  ref: 1.15.3-0-g337202d4e7179857bc37b03c1a6d8c9d92e47c44
