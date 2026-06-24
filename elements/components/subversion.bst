# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/subversion/-/raw/main/PKGBUILD?ref_type=heads
kind: autotools

description: A Modern Concurrent Version Control System

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- components/apr.bst
- components/apr-util.bst
- freedesktop-sdk.bst:components/expat.bst
- freedesktop-sdk.bst:components/lz4.bst
- freedesktop-sdk.bst:components/sqlite.bst
- freedesktop-sdk.bst:components/zlib.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  conf-local: >-
    --without-apxs
    --without-berkeley-db
    --without-swig
    --without-gnome-keyring
    --without-kwallet
    --disable-mod-activation
    --with-apr=/usr/bin/apr-1-config
    --with-apr-util=/usr/bin/apu-1-config
    --with-utf8proc=internal

sources:
- kind: tar
  url: https://downloads.apache.org/subversion/subversion-1.14.5.tar.bz2
  ref: e78a29e7766b8b7b354497d08f71a55641abc53675ce1875584781aae35644a1
