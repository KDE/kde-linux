# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/libva-intel-driver/-/raw/main/PKGBUILD?ref_type=heads
kind: meson

description: VA-API implementation for Intel G45 and HD Graphics family

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:extensions/mesa/libdrm.bst
- freedesktop-sdk.bst:components/libva.bst

sources:
- kind: git_repo
  url: github:irql-notlessorequal/intel-vaapi-driver.git
  track: '*'
  ref: 2.4.5-0-g0b648be50cd80e16469c135c76ff61bbd2f2d12b
