# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: meson

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libxkbcommon.bst

variables:
  meson-local: >-
    -Dtests=false
    -Dgtktsm=false

sources:
- kind: git
  url: github:kmscon/libtsm.git
  track: v4.5.0
  ref: 556373437d1c5f57f4dfc7c6cc1330e5088a4174
  ref-format: sha1
