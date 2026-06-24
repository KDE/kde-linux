# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/docker-compose/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: Fast, isolated development environments using Docker

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: github:docker/compose/archive/v5.1.4.tar.gz
  ref: 363ce6ccca46f836648f5f4ec9ecfdb6f631daa126570cc3fc69140edeed6794
