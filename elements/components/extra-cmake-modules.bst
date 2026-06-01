# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:sdk.bst

variables:
  cmake-local: -DBUILD_TESTING=OFF

public:
  bst:
    split-rules:
      devel:
        (>):
        - '**/*'

sources:
- url: kde:frameworks/extra-cmake-modules.git
  kind: git
  track: v6.27.0
  ref: fa262097a48f0f84529498741afcc7040e93b271
  ref-format: sha1
