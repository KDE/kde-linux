# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: compose

# Mind that we don't need to compose drivers we don't ship (e.g. nvidia) because they won't end up in the initrd
# but get loaded after the switch-root.
build-depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/systemd.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/linux.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/linux-firmware.bst
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/intel-ucode.bst
- os/os-release.bst
- os/systemd-initrd-mkosi-extra.bst

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
