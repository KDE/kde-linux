# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/opus-tools/-/raw/main/PKGBUILD?ref_type=heads
kind: autotools

description: Collection of tools for Opus audio codec

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/libogg.bst
- freedesktop-sdk.bst:components/opus.bst
- freedesktop-sdk.bst:components/opusfile.bst
- components/libopusenc.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libflac.bst
- freedesktop-sdk.bst:components/libogg.bst
- freedesktop-sdk.bst:components/opus.bst
- freedesktop-sdk.bst:components/opusfile.bst
- components/libopusenc.bst

sources:
- kind: tar
  url: https://downloads.xiph.org/releases/opus/opus-tools-0.2.tar.gz
  ref: b4e56cb00d3e509acfba9a9b627ffd8273b876b4e2408642259f6da28fa0ff86
