# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- components/openexr-imath.bst
- components/OpenJPH.bst

variables:
  cmake-local: -DOPENEXR_BUILD_TOOLS=OFF -DOPENEXR_BUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF

sources:
- url: https://github.com/AcademySoftwareFoundation/openexr.git
  kind: git
  track: v3.4.13
  ref: c1194b2cb23a1bdf76fe5e756b22e8436b9a98c9
  ref-format: sha1
