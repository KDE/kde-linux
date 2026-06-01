# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:sdk.bst
- qt/qtbase.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/polkit-gobject.bst

variables:
  cmake-local: -DQT_MAJOR_VERSION=6 -DBUILD_TESTING=OFF

sources:
- url: kde:libraries/polkit-qt-1.git
  kind: git
  track: v0.201.1
  ref: 328a4c8615c7207e1297b776026657a77c6a71b6
  ref-format: sha1
