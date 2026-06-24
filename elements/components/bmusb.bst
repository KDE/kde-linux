# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: make

description: a free driver for BlackMagic's Intensity Shuttle andUltraStudio SDI USB3 cards

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/pkg-config.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libusb.bst

sources:
- kind: git_repo
  url: http://git.sesse.net/bmusb
  ref: 0.7.8-0-g3615574c0d8c8564e1e091c8270f19138357777e
  track: '*.*.*'
