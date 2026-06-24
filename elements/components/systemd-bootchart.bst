# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/systemd-bootchart/-/raw/main/PKGBUILD?ref_type=heads
kind: autotools

description: Boot performance graphing tool

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/libxslt.bst
- freedesktop-sdk.bst:components/systemd.bst
- gnome-build-meta.bst:core-deps/intltool.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/systemd-libs.bst

config:
  configure-commands:
    (<):
    - ./autogen.sh

sources:
- kind: git_repo
  url: github:systemd/systemd-bootchart.git
  track: v*
  ref: v235-0-g8ab9680a1bd5eb8fe7a7dcc44897af7ee41e56e7
