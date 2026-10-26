# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Freedesktop-SDK Developers
# SPDX-FileCopyrightText: 2026 KDE Linux contributors

kind: meson

# This is needed because Freedesktop SDK's Plymouth uses pango as a backend and would result in
# slightly different kerning which messes with openQA's needle. Drop once we don't have two
# implementations.

build-depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/_private/git-minimal.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/docbook-xml.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/docbook-xsl.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/libxslt.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/systemd.bst

depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/freetype.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/gtk3.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/libdrm.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/libevdev.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/plymouth-logo.bst

variables:
  meson-local: >-
    -Dlogo="%{datadir}/pixmaps/kde-linux-logo.png"
    -Dpango=disabled
    -Dfreetype=enabled

sources:
- kind: git_repo
  url: freedesktop:plymouth/plymouth.git
  track: '*.*.*'
  ref: 26.134.222-0-gd15928a8e06c217aad0f2e3579df23fec93dc009
