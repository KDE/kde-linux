# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: make

description: Linux user-space application to modify the EFI Boot Manager

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/pkg-config.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/efivar.bst
- freedesktop-sdk.bst:components/popt.bst

variables:
  make-args: libdir=/usr/lib sbindir=/usr/bin EFIDIR=arch
  make-install-args: DESTDIR="%{install-root}" %{make-args} install

sources:
- kind: git_repo
  url: github:rhboot/efibootmgr
  track: '[0-9]*'
  ref: 18-0-gc3f9f0534e32158f62c43564036878b93b9e0fd6
