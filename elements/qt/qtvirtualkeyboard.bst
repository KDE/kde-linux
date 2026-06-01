# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:sdk.bst
- qt/qtbase.bst
- qt/qtdeclarative.bst
- qt/qtmultimedia.bst
- qt/qtsvg.bst
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{prefix}/bin'
        - '%{prefix}/bin/**'
sources:
- kind: tar
  url: qt:6.11/6.11.1/submodules/qtvirtualkeyboard-everywhere-src-6.11.1.tar.xz
  ref: a1c6967b326243b2ca8d50bc7b7f7852c3975d9aa6ce4b186ebdf35bb1007e1c
