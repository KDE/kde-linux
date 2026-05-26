# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: Lists open files for running Unix processes

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/groff.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libtirpc.bst

variables:
  conf-local: >-
    --enable-security
    --enable-no-sock-security
    --with-libtirpc

config:
  configure-commands:
    (<):
    - autoreconf -fiv

sources:
- kind: tar
  url: https://github.com/lsof-org/lsof/archive/refs/tags/4.99.6.tar.gz
  ref: 2ce65158694e9c44dfc54916f5b843d887763c03128e0a1c77d62ae106537009
