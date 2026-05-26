# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: make

description: View I/O usage of processes

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/pkg-config.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:bootstrap/ncurses.bst

environment:
  LDFLAGS: '-lncursesw -ltinfow'

variables:
  make-install: |
    install -Dm755 iotop "%{install-root}%{bindir}/iotop"
    install -Dm644 iotop.8 "%{install-root}%{mandir}/man8/iotop.8"

sources:
- kind: git_repo
  url: github:Tomas-M/iotop.git
  track: v1.30
  ref: c3366a8a235f9c8ddc4797625f22cfdf12ba2c36
