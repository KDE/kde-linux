# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: File compressor using lzo lib

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/lzo.bst

sources:
- kind: tar
  url: https://www.lzop.org/download/lzop-1.04.tar.gz
  ref: 7e72b62a8a60aff5200a047eea0773a8fb205caf7acbe1774d95147f305a2f41
