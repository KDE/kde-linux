# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

description: Generic command-line automation tool without X11 dependencies

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/scdoc.bst
- freedesktop-sdk.bst:components/systemd.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  cmake-local: -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_MANDIR=%{mandir} -DCMAKE_POLICY_VERSION_MINIMUM=3.5

config:
  install-commands:
    (>):
    - install -Dm644 80-uinput.rules "%{install-root}%{prefix}/lib/udev/rules.d/80-uinput.rules"

sources:
- kind: tar
  url: github:ReimuNotMoe/ydotool/archive/v1.0.4.tar.gz
  ref: ba075a43aa6ead51940e892ecffa4d0b8b40c241e4e2bc4bd9bd26b61fde23bd
- kind: local
  path: files
