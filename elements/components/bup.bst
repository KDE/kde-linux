# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/bup/-/raw/main/PKGBUILD?ref_type=heads
kind: make

description: Efficient backup system based on the git packfile format

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/git.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: git_repo
  url: github:bup/bup
  track: '*'
  ref: 0.33.10-0-g0fd0f5a8e928c9c93900f9d6f54fec61c855614a
