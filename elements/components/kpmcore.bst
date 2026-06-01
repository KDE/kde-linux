# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

description: Library for managing partitions

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/fontconfig.bst
- freedesktop-sdk.bst:components/harfbuzz.bst
- freedesktop-sdk.bst:components/libdbus.bst
- freedesktop-sdk.bst:components/libpng.bst
- freedesktop-sdk.bst:components/libxkbcommon.bst
- freedesktop-sdk.bst:components/mesa-headers.bst
- freedesktop-sdk.bst:components/polkit-gobject.bst
- components/extra-cmake-modules.bst
- components/kcoreaddons.bst
- components/ki18n.bst
- components/kwidgetsaddons.bst
- components/polkit-qt-1.bst
- qt.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  cmake-local: >-
    -DBUILD_TESTING=OFF

sources:
- kind: git
  url: kde:system/kpmcore
  track: v25.12.3
  ref: b348efa14a9511ec4c0c3c523bb255a910b402d0
