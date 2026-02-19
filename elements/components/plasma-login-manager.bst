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
  cmake-local: -DBUILD_TESTING=OFF -DPAM_OS_CONFIGURATION=kde-linux

config:
  install-commands:
    (>):
    - |
      install -Dm644 pam/* -t "%{install-root}%{sysconfdir}/pam.d/"

sources:
- kind: git
  url: kde:plasma/plasma-login-manager.git
  track: Plasma/6.7
  ref: 83766fd3d090e9fad0bfbee4e2a22ed219642a0b
- kind: local
  path: files/
