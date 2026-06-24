# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

description: Additional completion definitions for zsh

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- components/zsh.bst

config:
  install-commands:
  - install -dm755 "%{install-root}%{datadir}/zsh/site-functions"
  - cp -a src/_* "%{install-root}%{datadir}/zsh/site-functions/"

sources:
- kind: git_repo
  url: github:zsh-users/zsh-completions.git
  track: 0.36.0
  ref: 0.36.0-0-g28c5bdcaf81bb89e56d0df8267d822c3b8aed9e0
