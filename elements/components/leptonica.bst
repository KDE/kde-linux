# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: Leptonica is a pedagogically-oriented open source library containing software that is broadly useful for image processing and image analysis applications

depends:
- freedesktop-sdk.bst:components/giflib.bst
- freedesktop-sdk.bst:components/libpng.bst
- freedesktop-sdk.bst:components/libtiff.bst
- freedesktop-sdk.bst:components/libwebp.bst
- freedesktop-sdk.bst:components/openjpeg.bst
- freedesktop-sdk.bst:components/zlib.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

sources:
- kind: tar
  url: github:DanBloomberg/leptonica/archive/1.87.0/leptonica-1.87.0.tar.gz
  ref: fa2b40c5caea96d1bb93a97486262aed8731b69ce25a84a6bf5d25323e33f631
