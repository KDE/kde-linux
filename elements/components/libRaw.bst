# SPDX-FileCopyrightText: Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: A library for reading RAW files from digital cameras (CRW/CR2, NEF, RAF, DNG, and others)

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/lcms.bst
- freedesktop-sdk.bst:components/jpeg.bst
- freedesktop-sdk.bst:components/zlib.bst

config:
  configure-commands:
    (<):
    - |
      autoreconf -fiv

sources:
- kind: git_repo
  url: github:LibRaw/LibRaw.git
  track: 0.22.1
  ref: b860248a89d9082b8e0a1e202e516f46af9adb29
