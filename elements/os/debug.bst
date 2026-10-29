# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

kind: script

build-depends:
- kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- filename: os/debug-compose.bst
  config:
    location: /debug

variables:
  install-root: /debug

config:
  commands:
  # filesystem.bst drops these binaries, no point shipping their symbols.
  - rm /debug/usr/lib/debug/usr/bin/lto-dump.debug
  - rm /debug/usr/lib/debug/usr/bin/llvm-exegesis.debug
