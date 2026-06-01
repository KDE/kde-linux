# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:sdk.bst

variables:
  cmake-local: -DBUILD_DEPENDENCIES=LOCAL -DBUILD_SHARED_LIBS=ON -DBUILD_UNIT_TESTS=OFF -DBUILD_BLACKBOX_TESTS=OFF -DBUILD_EXAMPLES=OFF

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{prefix}/include/ZXing'
        - '%{prefix}/include/ZXing/**'
        - '**/*.pc'
        - '%{prefix}/lib/*/cmake/ZXing'
        - '**/libZXing.so'
        - '**/libZXing.so/**'

sources:
- kind: tar
  url: github:zxing-cpp/zxing-cpp/archive/v2.3.0.tar.gz
  ref: 64e4139103fdbc57752698ee15b5f0b0f7af9a0331ecbdc492047e0772c417ba
