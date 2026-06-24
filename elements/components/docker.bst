# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/docker/-/raw/main/PKGBUILD?ref_type=heads
kind: cmake

description: Pack, ship and run any application as a lightweight container

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: git_repo
  url: github:docker/cli.git
  track: 'v*'
  ref: v29.6.0-rc.1-0-g1d1562e0049a5fa0e8d7445a26253a8fbdc6a130
