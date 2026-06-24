# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/orca/-/raw/main/PKGBUILD?ref_type=heads
kind: meson

description: Screen reader for individuals who are blind or visually impaired

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/at-spi2-core.bst
- freedesktop-sdk.bst:components/gtk3.bst
- freedesktop-sdk.bst:components/pygobject.bst
- freedesktop-sdk.bst:components/itstool.bst

sources:
- kind: git_repo
  url: https://gitlab.gnome.org/GNOME/orca.git
  track: '48.*'
  ref: 48.9-0-g4b964097f586446b3c74a98d0d309fb4b87ceb70
