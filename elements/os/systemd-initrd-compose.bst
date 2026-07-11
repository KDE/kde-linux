# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: compose

build-depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/systemd.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/linux.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/linux-firmware.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/plymouth.bst
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/intel-ucode.bst
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/nvidia-drivers-modules.bst
- os/os-release.bst

config:
  exclude:
  - debug
  - doc
  - tests
  - devel
  - shells
  - zoneinfo
  - locale
  include-orphans: True
