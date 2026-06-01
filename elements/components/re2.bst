# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/abseil-cpp.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/abseil-cpp.bst

config:
  build-commands:
  - make shared CXXFLAGS="${CXXFLAGS} -std=c++20"
  install-commands:
  - >-
    make
    DESTDIR="%{install-root}"
    prefix="%{prefix}"
    includedir="%{includedir}"
    libdir="%{libdir}"
    shared-install

sources:
- kind: tar
  url: github:google/re2/archive/2025-11-05/re2-2025-11-05.tar.gz
  ref: 87f6029d2f6de8aa023654240a03ada90e876ce9a4676e258dd01ea4c26ffd67
