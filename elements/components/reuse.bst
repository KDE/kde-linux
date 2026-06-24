# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/reuse/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: Helper tool for providing and confirming copyright and licensing information

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: git_repo
  url: github:fsfe/reuse-tool
  track: 'v*'
  ref: v6.2.0-0-ga1bb792acda6fd0724936b4ebbdbc8eceb9c0459
