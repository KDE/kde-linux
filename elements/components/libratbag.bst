# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/libratbag/-/raw/main/PKGBUILD?ref_type=heads
kind: meson

description: A DBus daemon to configure gaming mice

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/json-glib.bst
- freedesktop-sdk.bst:components/libevdev.bst
- freedesktop-sdk.bst:components/libunistring.bst
- freedesktop-sdk.bst:components/pygobject.bst
- freedesktop-sdk.bst:components/swig.bst
- freedesktop-sdk.bst:components/systemd.bst
- components/libcheck.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  meson-local: >-
    -Ddocumentation=false

sources:
- kind: git_repo
  url: github:libratbag/libratbag.git
  track: 'v*'
  ref: v0.18-0-g9f4789f8746188a75cd3090e94adf984f0ac4cc6
