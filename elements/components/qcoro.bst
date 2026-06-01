# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake
build-depends:
- freedesktop-sdk.bst:sdk.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- qt.bst

variables:
  cmake-local: -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON

sources:
- kind: git_repo
  url: https://github.com/qcoro/qcoro.git
  track: v*
  ref: v0.13.0-0-g98f23d8d8d67e9e24217d268927faec97c713fb0
