# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

description: Fish shell-like syntax highlighting for zsh

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- components/zsh.bst

config:
  install-commands:
  - install -Dm644 zsh-syntax-highlighting.zsh "%{install-root}%{datadir}/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  - cp -a highlighters "%{install-root}%{datadir}/zsh/plugins/zsh-syntax-highlighting/"

sources:
- kind: git_repo
  url: github:zsh-users/zsh-syntax-highlighting.git
  track: 0.8.0
  ref: 0.8.0-0-gdb085e4661f6aafd24e5acb5b2e17e4dd5dddf3e
