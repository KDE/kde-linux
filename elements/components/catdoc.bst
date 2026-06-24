# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/catdoc/-/raw/main/PKGBUILD?ref_type=heads
kind: autotools

description: A convertor for Microsoft Word, Excel, PowerPoint and RTF Files to text

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst


config:
  install-commands:
  - make -j1 DESTDIR="%{install-root}" installroot="%{install-root}" install

sources:
- kind: tar
  url: http://ftp.wagner.pp.ru/pub/catdoc/catdoc-0.95.tar.gz
  ref: 514a84180352b6bf367c1d2499819dfa82b60d8c45777432fa643a5ed7d80796
