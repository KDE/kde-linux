# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/unrar/-/raw/main/PKGBUILD?ref_type=heads
kind: make

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  make-install: |
    make -j1 %{make-install-args}
    install -Dm755 "%{install-root}/bin/unrar" "%{install-root}%{bindir}/unrar"
    rm -rf "%{install-root}/bin"

sources:
- kind: tar
  url: https://www.rarlab.com/rar/unrarsrc-7.2.6.tar.gz
  ref: d1afa67ef4121ebc5986815699e05db0ce8648499e5dca854f282a4c3f72c003
