# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/jxrlib/-/raw/main/PKGBUILD?ref_type=heads
kind: make

description: Open source implementation of jpegxr

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/python3.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  make-install-args: DIR_INSTALL=%{install-root}/usr/lib/jxrlib %{make-args} install

sources:
- kind: git_repo
  url: github:mircomir/jxrlib
  track: '*'
  ref: 1.4.1-0-g4e85af2726022fb40439a558e92f7e1297eb13ef
