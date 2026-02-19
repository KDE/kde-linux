# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

build-depends:
- org.kde.Sdk.bst
- org.kde.plasma.desktop.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/systemd.bst

variables:
  cmake-local: -DBUILD_TESTING=OFF

sources:
- kind: git
  url: kde:plasma/polkit-kde-agent-1.git
  track: Plasma/6.7
  ref: e83aa1fdfc6593b9d4a5b2285ec584f05e207894
