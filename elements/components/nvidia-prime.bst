# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-prime/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: NVIDIA Prime Render Offload configuration and utilities

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: remote
  url: https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-prime/-/raw/main/prime-run?ref_type=heads
  ref: c2441e74c19779c8e0cf0d212e9a9e5ef50a00c403caef78266e2ebb2e360e3c
- kind: remote
  url: https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-prime/-/raw/main/LICENSE?ref_type=heads
  ref: 7056c04df17a4e0f0bac9f787f347c9cd892cee6323d1c89528090afd0b934a3
