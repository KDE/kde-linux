# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: make

sources:
- kind: git_repo
  url: sipsolutions:iw.git
  track: v5.19
  ref: v5.19-0-g79f20cbf1a333a23e3b041d502277d240aedb840

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/gzip.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libnl.bst

variables:
  make-args: >-
    PREFIX="%{prefix}"
    SBINDIR="%{sbindir}"
