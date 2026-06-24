# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/fastfetch/-/raw/main/PKGBUILD?ref_type=heads
kind: cmake

description: A feature-rich and performance oriented neofetch like system information tool

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/libdrm.bst
- freedesktop-sdk.bst:components/libva.bst
- freedesktop-sdk.bst:components/sqlite.bst
- freedesktop-sdk.bst:components/vulkan-headers.bst
- freedesktop-sdk.bst:components/vulkan-icd-loader.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/zlib.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  cmake-local: >-
    -DBUILD_FLASHFETCH=OFF
    -DBUILD_TESTS=OFF
    -DENABLE_SQLITE3=ON
    -DENABLE_RPM=OFF
    -DENABLE_IMAGEMAGICK6=OFF
    -DENABLE_SYSTEM_YYJSON=OFF
    -DPACKAGES_DISABLE_APK=ON
    -DPACKAGES_DISABLE_DPKG=ON
    -DPACKAGES_DISABLE_EMERGE=ON
    -DPACKAGES_DISABLE_EOPKG=ON
    -DPACKAGES_DISABLE_GUIX=ON
    -DPACKAGES_DISABLE_LINGLONG=ON
    -DPACKAGES_DISABLE_LPKG=ON
    -DPACKAGES_DISABLE_LPKGBUILD=ON
    -DPACKAGES_DISABLE_OPKG=ON
    -DPACKAGES_DISABLE_PACSTALL=ON
    -DPACKAGES_DISABLE_PALUDIS=ON
    -DPACKAGES_DISABLE_PKG=ON
    -DPACKAGES_DISABLE_PKGTOOL=ON
    -DPACKAGES_DISABLE_RPM=ON
    -DPACKAGES_DISABLE_SORCERY=ON
    -DPACKAGES_DISABLE_XBPS=ON
    -Wno-dev

sources:
- kind: tar
  url: github:fastfetch-cli/fastfetch/archive/refs/tags/2.64.2.tar.gz
  ref: 28db81d6568f28281d9aab9e88d5a4c7892d519c54b8739eef17953cce6802d0
