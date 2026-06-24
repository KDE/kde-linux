# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/android-tools/-/raw/main/PKGBUILD?ref_type=heads
kind: cmake

description: Android platform tools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/abseil-cpp.bst
- freedesktop-sdk.bst:components/brotli.bst
- freedesktop-sdk.bst:components/libusb.bst
- freedesktop-sdk.bst:components/lz4.bst
- freedesktop-sdk.bst:components/protobuf.bst
- freedesktop-sdk.bst:components/zstd.bst
- gnome-build-meta.bst:boards/common/libgtest.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  cmake-local: >-
    -DANDROID_TOOLS_USE_BUNDLED_FMT=ON
    -DANDROID_TOOLS_USE_BUNDLED_LIBUSB=ON
    -DANDROID_TOOLS_LIBUSB_ENABLE_UDEV=ON
    -Dprotobuf_MODULE_COMPATIBLE=ON

sources:
- kind: tar
  url: github:nmeum/android-tools/releases/download/35.0.2/android-tools-35.0.2.tar.xz
  ref: d2c3222280315f36d8bfa5c02d7632b47e365bfe2e77e99a3564fb6576f04097
- kind: patch
  path: elements/components/patch/android-tools-35.0.2-fix-protobuf-30.0-compilation.patch
- kind: patch
  path: elements/components/patch/android-tools-35.0.2-gcc-16.patch
