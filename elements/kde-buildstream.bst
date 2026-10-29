# SPDX-FileCopyrightText: 2026 KDE Linux Contributors
# SPDX-License-Identifier: BSD-2-Clause

kind: junction

sources:
- kind: git_repo
  url: invent:packaging/kde-buildstream.git
  track: work/apol/gen-kde
  ref: 71f88f79e7e8c8cebde2ebadc36bc63d360beb5b

config:
  overrides:
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
