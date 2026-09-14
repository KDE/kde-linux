# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 KDE Linux contributors

kind: manual

build-depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/noto-fonts.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - |
    install -Dm644 -t "%{install-root}/usr/share/fonts/noto" \
      /usr/share/fonts/noto/NotoSans-Regular.ttf \
      /usr/share/fonts/noto/NotoSans-Light.ttf
