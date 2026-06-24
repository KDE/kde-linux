# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/thermald/-/raw/main/PKGBUILD?ref_type=heads
kind: autotools

description: The Linux Thermal Daemon program from 01.org

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/gtk-doc.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/libevdev.bst
- components/upower.bst

sources:
- kind: git_repo
  url: github:intel/thermal_daemon.git
  track: 'v*'
  ref: v2.15.10-0-g88369b42ec523787081b9bf8811b364e2a3d5f2d
