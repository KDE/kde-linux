# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/python-pyudev/-/raw/main/PKGBUILD?ref_type=heads

kind: manual

description: Python bindings to libudev

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: git_repo
  url: github:pyudev/pyudev.git
  track: v0.24.4
  ref: v0.24.4-0-g643027533a9a5dee7f80c0a7348ad85fbae7f0fa
