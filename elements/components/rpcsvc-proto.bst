# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools
sources:
- kind: git_repo
  url: github:thkukuk/rpcsvc-proto.git
  track: 'v*'
  ref: v1.4.4-0-gc65926005e50da02a4da3e26abc42eded36cd19d
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
variables:
  autogen: |
    autoreconf -fvi
