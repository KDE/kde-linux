# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/system-config-printer/-/raw/main/PKGBUILD?ref_type=heads
kind: autotools

description: A CUPS printer configuration tool and status applet

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:sdk.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/xmlto.bst

sources:
- kind: tar
  url: github:OpenPrinting/system-config-printer/releases/download/v1.5.18/system-config-printer-1.5.18.tar.xz
  ref: b1a69e1b4ec2add569a87aeca811a37c5361ee6ae327ec852b79e64223e34bee
