# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:sdk.bst
- components/extra-cmake-modules.bst
- qt.bst

public:
  bst:
    split-rules:
      devel:
        (>):
        - '**/*'

variables:
  cmake-local: -DBUILD_TESTING=OFF -DBUILD_PYTHON_BINDINGS=OFF -DBUILD_DESIGNERPLUGIN=OFF

sources:
- url: kde:frameworks/kwidgetsaddons.git
  kind: git
  track: v6.27.0
  ref: 7e19d066d8b51fd348f24ca9e1a74258ba54fbcb
  ref-format: sha1
