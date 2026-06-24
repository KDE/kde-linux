# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/lshw/-/raw/main/PKGBUILD?ref_type=heads
kind: make

description: A small tool to provide detailed information on the hardware configuration of the machine.

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/gettext.bst
- freedesktop-sdk.bst:components/git.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  make-install: |
    make PREFIX="%{install-root}%{prefix}" install
    install -Dm755 "%{install-root}%{prefix}/sbin/lshw" "%{install-root}%{bindir}/lshw"
    rm -rf "%{install-root}%{prefix}/sbin"

sources:
- kind: git_repo
  url: https://ezix.org/src/pkg/lshw.git
  track: 'B.*'
  ref: B.02.20-0-g4c6497c8b0a67cd9fa9693e9101a7cafd3297e81
