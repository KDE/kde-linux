# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

description: Zsh port of Fish history search

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- components/zsh.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm644 zsh-history-substring-search.zsh "%{install-root}%{datadir}/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

sources:
- kind: git_repo
  url: github:zsh-users/zsh-history-substring-search.git
  track: v1.1.0
  ref: v1.1.0-0-g400e58a87f72ecec14f783fbd29bc6be4ff1641c
