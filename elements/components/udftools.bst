# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/udftools/-/raw/main/PKGBUILD?ref_type=heads
kind: autotools

description: Linux tools for UDF filesystems and DVD/CD-R(W) drives

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  configure-commands:
    (<):
    - ./autogen.sh

sources:
- kind: git_repo
  url: github:pali/udftools.git
  track: '*'
  ref: 2.3-0-ga9bbe6a80fe208304770035e99149f2131bc7571
