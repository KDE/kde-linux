# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: PowerTOP

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:bootstrap/ncurses.bst
- freedesktop-sdk.bst:components/libnl.bst
- freedesktop-sdk.bst:components/pciutils.bst

config:
  configure-commands:
    (<):
    - |
      ./autogen.sh

sources:
- kind: git_repo
  url: github:fenrus75/powertop.git
  track: 'v[0-9]*'
  exclude:
  - '*rc*'
  - '*pre*'
  - '*internal*'
  ref: v2.14-0-g52f022f9bbe6e060fba11701d657a8d9762702ba
