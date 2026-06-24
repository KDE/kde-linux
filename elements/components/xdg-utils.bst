# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/xdg-utils/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: Command line tools that assist applications with a variety of desktop integration tasks

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  build-commands:
  - ./configure --prefix="%{prefix}"
  - |
    for script in xdg-desktop-menu xdg-desktop-icon xdg-mime xdg-icon-resource xdg-open xdg-email xdg-screensaver xdg-settings; do
      : > "scripts/${script}.txt"
    done
  - make -C scripts scripts
  install-commands:
  - make -C scripts DESTDIR="%{install-root}" install

sources:
- kind: git_repo
  url: fdo:xdg/xdg-utils.git
  track: 'v*'
  ref: v1.2.1-0-g356c380ad6fecc9ce6bea1f6a77986ba67402c80
