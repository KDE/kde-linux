# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: A validating XML parser written in a portable subset of C++

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/curl.bst
- freedesktop-sdk.bst:components/icu.bst

sources:
- kind: tar
  url: https://archive.apache.org/dist/xerces/c/3/sources/xerces-c-3.3.0.tar.gz
  ref: 9555f1d06f82987fbb4658862705515740414fd34b4db6ad2ed76a2dc08d3bde
