# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

description: Calamares system installer

build-depends:
- org.kde.Sdk.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/polkit.bst
- components/polkit-qt-1.bst
- components/yamlcpp.bst
- components/kpmcore.bst

variables:
  cmake-local: >-
    -DBUILD_TESTING=OFF
    -DWITH_QT6=ON

sources:
- kind: git
  url: https://codeberg.org/Calamares/calamares.git
  track: v3.4.0
  ref: 78d4208a03b0abdfb68e94c9c08a28f37a473ee6
