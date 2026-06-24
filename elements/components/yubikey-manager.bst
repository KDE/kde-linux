# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/yubikey-manager/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: Python library and command line tool for configuring a YubiKey

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: github:Yubico/yubikey-manager/releases/download/5.9.1/yubikey_manager-5.9.1.tar.gz
  ref: 83bda2a4bbb6a93bc07e5de73a0f30e5a8b811c85a9116aaca6dd3eed8abb0eb
