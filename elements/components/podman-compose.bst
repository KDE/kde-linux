# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/podman-compose/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: A script to run docker-compose.yml using podman

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: github:containers/podman-compose/archive/v1.6.0.tar.gz
  ref: dffdec88deb6da8437a86d82340e213c3a616933807fe3fd5978f0c8c325e5e2
