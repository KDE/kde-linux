# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: manual

description: Pretend we are debian so cmake and meson put libs in the right path

build-depends:
  - kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - |
    mkdir --parents "%{install-root}/etc"
    touch "%{install-root}/etc/debian_version"
  - |
    # meson also asks dpkg for the actual multiarch tuples, let's oblige
    mkdir --parents "%{install-root}/usr/bin"
    echo '#!/bin/sh' > "%{install-root}/usr/bin/dpkg-architecture"
    echo 'echo "%{gcc_triplet}"' >> "%{install-root}/usr/bin/dpkg-architecture"
    chmod +x "%{install-root}/usr/bin/dpkg-architecture"
