# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: Apache Portable Runtime Utility Library

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- components/apr.bst
- freedesktop-sdk.bst:components/expat.bst
- freedesktop-sdk.bst:components/sqlite.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- components/apr.bst

variables:
  conf-local: >-
    --with-apr=/usr/bin/apr-1-config
    --without-berkeley-db
    --without-ldap
    --without-crypto

sources:
- kind: tar
  url: https://downloads.apache.org/apr/apr-util-1.6.3.tar.bz2
  ref: a41076e3710746326c3945042994ad9a4fcac0ce0277dd8fea076fec3c9772b5
