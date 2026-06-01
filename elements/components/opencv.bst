# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:sdk.bst

variables:
  cmake-local: -DCMAKE_BUILD_TYPE=Release -DOPENCV_GENERATE_PKGCONFIG=ON -DBUILD_LIST=imgproc

sources:
- kind: tar
  url: github:opencv/opencv/archive/4.12.0.tar.gz
  ref: 44c106d5bb47efec04e531fd93008b3fcd1d27138985c5baf4eafac0e1ec9e9d
- kind: tar
  url: github:opencv/opencv_contrib/archive/4.12.0.tar.gz
  ref: 4197722b4c5ed42b476d42e29beb29a52b6b25c34ec7b4d589c3ae5145fee98e
