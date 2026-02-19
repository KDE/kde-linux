# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

description: Library for managing partitions

build-depends:
- org.kde.plasma.desktop.bst # polkit-qt-1

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
