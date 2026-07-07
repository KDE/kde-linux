# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: junction

sources:
- kind: git_repo
  url: invent:kde-linux/kde-linux-packages.git
  track: work/sitter/bst
  ref: 04e9990cb451abdd9b0fc0a64079d19e709c1358

config:
  overrides:
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
