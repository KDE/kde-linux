# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/quota-tools/-/raw/main/PKGBUILD?ref_type=heads
kind: autotools

description: Tools to manage kernel-level quotas in Linux

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: https://downloads.sourceforge.net/sourceforge/linuxquota/quota-4.11.tar.gz
  ref: 0a51b8f920254d8e83c34a4c3082b7d241f5d6fd65188afadf29859d5223ef78
