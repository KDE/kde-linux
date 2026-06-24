# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/pyatspi/-/raw/main/PKGBUILD?ref_type=heads
kind: meson

description: Python bindings for D-Bus AT-SPI

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/pygobject.bst

sources:
- kind: git_repo
  url: https://gitlab.gnome.org/GNOME/pyatspi2.git
  track: '*'
  ref: 2.58.2-0-gf2fb289a9d2e4dac65fca8db0f4d3d65607a0cf2
