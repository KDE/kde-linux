# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/btrfsmaintenance/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: Btrfs maintenance scripts

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: github:kdave/btrfsmaintenance/archive/v0.5.2.tar.gz
  ref: f41f5c8a697420c282c603d96f70b25a6f4d3bf330fa0249625bce256e0cce2e
