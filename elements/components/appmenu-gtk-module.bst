# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/appmenu-gtk-module/-/raw/main/PKGBUILD?ref_type=heads
kind: meson

description: Application Menu GTK Module

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/vala.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/gtk3.bst

variables:
  command-subdir: subprojects/appmenu-gtk-module
  meson-local: >-
    -Dgtk=3

sources:
- kind: git_repo
  url: gitlab:vala-panel-project/vala-panel-appmenu
  track: '*'
  ref: 25.04-0-g8c8e788bf04c8c2911b72a24e3b79842d5b2b286
