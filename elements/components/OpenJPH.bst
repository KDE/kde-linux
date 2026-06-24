# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

variables:
  cmake-local: -DOJPH_ENABLE_TIFF_SUPPORT=OFF -DOJPH_BUILD_EXECUTABLES=OFF

sources:
- url: https://github.com/aous72/OpenJPH.git
  kind: git
  track: 0.22.0
  ref: be997ab52ffc73e0fd9d66108ad786925a1c712c
  ref-format: sha1
