# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/xmlsec/-/raw/main/PKGBUILD?ref_type=heads
kind: autotools

description: XML Security Library is a C library based on LibXML2

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/openssl.bst

sources:
- kind: tar
  url: github:lsh123/xmlsec/releases/download/1.3.12/xmlsec1-1.3.12.tar.gz
  ref: 24045199af12d93fe5fdbbbf7e386e823e4842071e9432e2b90ac108b889a923
