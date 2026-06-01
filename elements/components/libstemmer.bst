# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/perl.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: git_repo
  url: github:snowballstem/snowball.git
  track: v*

  ref: v3.1.1-0-gcd195b51e948a902a4312f023f4a14392516a543
config:
  build-commands:
  - make

  install-commands:
  - install -Dm644 include/libstemmer.h -t "%{install-root}%{includedir}"
  - install -Dm644 libstemmer.a -t "%{install-root}%{libdir}"
  - install -Dm644 COPYING -t "%{install-root}%{datadir}/licenses/snowball"
