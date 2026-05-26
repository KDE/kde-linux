# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: Multi-threaded compression with rzip/lzma, lzo, and zpaq

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/lzo.bst
- freedesktop-sdk.bst:components/lz4.bst

environment:
  CFLAGS: '-fomit-frame-pointer'
  CXXFLAGS: '-fomit-frame-pointer'

config:
  configure-commands:
  - ./autogen.sh --prefix=/usr

  install-commands:
  - make DESTDIR="%{install-root}" install-strip

sources:
- kind: git_repo
  url: github:ckolivas/lrzip.git
  track: v0.660
  ref: b9e8784d8d6806e733d0b4207731bf895d1c14db
