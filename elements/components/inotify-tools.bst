# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: inotify-tools is a C library and a set of command-line programs for Linux providing a simple interface to inotify.

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/doxygen.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  conf-local: --enable-fanotify

config:
  configure-commands:
    (<):
    - |
      ./autogen.sh

sources:
- kind: tar
  url: https://github.com/inotify-tools/inotify-tools/archive/refs/tags/4.25.9.0.tar.gz
  ref: d33a4fd24c72c2d08893f129d724adf725b93dae96c359e4f4e9f32573cc853b
