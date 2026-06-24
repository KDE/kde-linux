# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

description: Free Lossless Audio Codec

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/libogg.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libogg.bst

variables:
  cmake-local: >-
    -DBUILD_CXXLIBS=OFF
    -DBUILD_DOCS=OFF
    -DBUILD_EXAMPLES=OFF
    -DBUILD_PROGRAMS=OFF
    -DBUILD_TESTING=OFF
    -DINSTALL_MANPAGES=OFF

sources:
- kind: tar
  url: https://downloads.xiph.org/releases/flac/flac-1.5.0.tar.xz
  ref: f2c1c76592a82ffff8413ba3c4a1299b6c7ab06c734dee03fd88630485c2b920
