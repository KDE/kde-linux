# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: https://www.libssh.org/files/0.12/libssh-0.12.0.tar.xz
  ref: 1a6af424d8327e5eedef4e5fe7f5b924226dd617ac9f3de80f217d82a36a7121
