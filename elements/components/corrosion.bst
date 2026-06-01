# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

variables:
  cmake-local: -DBUILD_TESTING=OFF

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/rust.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: git_repo
  url: https://github.com/corrosion-rs/corrosion.git
  track: v*
  ref: v0.6.1-0-g1499b14e4906a2890f5cee1547c8848db261753d
