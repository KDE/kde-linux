# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: make

description: Next generation secure network tunnel - tools for configuration

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:bootstrap/bash.bst

variables:
  make: make -C src/
  make-install: >-
    make -C src/
    DESTDIR="%{install-root}"
    WITH_BASHCOMPLETION=yes
    WITH_WGQUICK=yes
    WITH_SYSTEMDUNITS=yes
    install

config:
  install-commands:
    (>):
    - |
      install -d -m0755 "%{install-root}%{datadir}/wireguard-tools/"
      cp -r contrib/ "%{install-root}%{datadir}/wireguard-tools/examples/"

sources:
- kind: git_repo
  url: https://git.zx2c4.com/wireguard-tools
  track: v1.0.20260223
  ref: 49ce333da02056ae7b22ee2aeb6afe8aaed79b19
