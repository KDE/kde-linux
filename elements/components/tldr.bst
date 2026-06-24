# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/tldr/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: Command line client for tldr, a collection of simplified man pages.

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: github:tldr-pages/tldr-python-client/archive/3.4.4/tldr-3.4.4.tar.gz
  ref: 374e01c62148bb7142fdf79a8756dbd08408b3db2117b9f8c51e1ccab5f75d06
