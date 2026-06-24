# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/trash-cli/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: Command line trashcan (recycle bin) interface

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: github:andreafrancia/trash-cli/archive/0.24.5.26.tar.gz
  ref: 1d7dec1ad8f0264ceb1b0211d25fffee99c9409cd2e1d36dcc82ac5540f39ce5
