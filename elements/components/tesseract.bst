# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: This package contains an OCR engine - libtesseract and a command line program - tesseract

depends:
- freedesktop-sdk.bst:components/gcc-libs.bst
- freedesktop-sdk.bst:components/curl.bst
- freedesktop-sdk.bst:components/libarchive.bst
- components/leptonica.bst

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/icu.bst
- freedesktop-sdk.bst:components/pango.bst
- freedesktop-sdk.bst:components/asciidoc.bst

sources:
- kind: tar
  url: github:tesseract-ocr/tesseract/archive/5.5.2/tesseract-5.5.2.tar.gz
  ref: 6235ea0dae45ea137f59c09320406f5888383741924d98855bd2ce0d16b54f21

config:
  build-commands:
    (>):
    - |
      make training

  install-commands:
    (>):
    - |
      make DESTDIR="%{install-root}" training-install
