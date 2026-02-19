# SPDX-FileCopyrightText: 2026 Aleix Pol i Gonzalez <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: make

sources:
- kind: tar
  url: github:hramrach/lm-sensors/archive/refs/tags/V3-6-2.tar.gz
  ref: c6a0587e565778a40d88891928bf8943f27d353f382d5b745a997d635978a8f0

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:components/bison.bst

variables:
  make: make PREFIX="%{prefix}"

  make-install: >-
    make BUILD_STATIC_LIB=0
    PREFIX="%{prefix}" SBINDIR="%{bindir}" MANDIR="%{mandir}"
    DESTDIR="%{install-root}" install
