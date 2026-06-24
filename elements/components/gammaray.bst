# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/fontconfig.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/libxkbcommon.bst
- freedesktop-sdk.bst:components/mesa-headers.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- qt.bst

variables:
  cmake-local: >-
    -DBUILD_TESTING=OFF
    -DGAMMARAY_BUILD_DOCS=OFF

sources:
- kind: git_repo
  url: github:KDAB/GammaRay
  track: 'v*'
  ref: v3.4.0-0-g731f7cdbf742470ad11ba9598a6bc47f40d7f943
