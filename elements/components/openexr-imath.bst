# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

sources:
- url: https://github.com/AcademySoftwareFoundation/Imath.git
  kind: git
  track: v3.2.2
  ref: 1e480d11cb98b032a2dece9b9a8730512effc7f6
  ref-format: sha1
