# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

build-depends:
- org.kde.Sdk.bst
- org.kde.plasma.desktop.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/flatpak.bst
- components/appstreamqt.bst

variables:
  cmake-local: -DBUILD_TESTING=OFF -DBUILD_SystemdSysupdateBackend=ON

sources:
- kind: git
  url: kde:plasma/discover.git
  track: Plasma/6.7
  ref: 007970ef9d666d2bcac05a574de6e9cff646bcff
