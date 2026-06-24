# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/switcheroo-control/-/raw/main/PKGBUILD?ref_type=heads
kind: meson

description: D-Bus service to check the availability of dual-GPU

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/libdrm.bst
- freedesktop-sdk.bst:components/systemd.bst

sources:
- kind: git_repo
  url: https://gitlab.freedesktop.org/hadess/switcheroo-control
  track: '3.*'
  ref: 3.0-0-g2adfa2dff85b9886ce0fddca6863fe9f2eaf54a0
