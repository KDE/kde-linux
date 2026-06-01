# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:sdk.bst

variables:
  cmake-local: -DEXIV2_BUILD_EXIV2_COMMAND=OFF -DEXIV2_BUILD_SAMPLES=OFF -DEXIV2_ENABLE_INIH=OFF
    -DEXIV2_ENABLE_VIDEO=OFF

sources:
- kind: zip
  url: github:Exiv2/exiv2/archive/refs/tags/v0.28.3.zip
  ref: 8d52df122b113d66889c147505ade41ff1a6396e9e467db43f7dd6712d98226d
