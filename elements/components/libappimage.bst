# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/libappimage/-/raw/main/PKGBUILD?ref_type=heads
kind: cmake

description: Reference implementation of the AppImage specification

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  cmake-local: -DCMAKE_POLICY_VERSION_MINIMUM=3.5

sources:
- kind: git_repo
  url: github:AppImage/libappimage
  track: 'v*'
  ref: v1.0.4-5-0-g7acfb43e150e9a55e2602631596258925da167eb
