# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

description: Fish-like autosuggestions for zsh

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- components/zsh.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm644 zsh-autosuggestions.zsh "%{install-root}%{datadir}/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

sources:
- kind: git_repo
  url: github:zsh-users/zsh-autosuggestions.git
  track: v0.7.1
  ref: v0.7.1-0-ge52ee8ca55bcc56a17c828767a3f98f22a68d4eb
