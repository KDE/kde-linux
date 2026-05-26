# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

description: Udev rules for Logitech receivers

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

sources:
- kind: git_repo
  url: github:pwr-Solaar/Solaar.git
  track: 1.1.19

  ref: 4bda869542ea0b2e54f24decd4cca65113679e25
config:
  install-commands:
  - |
    install -Dm644 rules.d-uinput/42-logitech-unify-permissions.rules \
      "%{install-root}%{prefix}/lib/udev/rules.d/42-logitech-unify-permissions.rules"
