# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: Apache Portable Runtime

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: https://downloads.apache.org/apr/apr-1.7.6.tar.bz2
  ref: 49030d92d2575da735791b496dc322f3ce5cff9494779ba8cc28c7f46c5deb32
