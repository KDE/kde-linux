# SPDX-FileCopyrightText: 2026 KDE Linux Contributors
# SPDX-License-Identifier: BSD-2-Clause

kind: junction

sources:
- kind: git_repo
  url: invent:packaging/kde-buildstream.git
  track: work/apol/gen-kde
  ref: 7237a152398b1b3d5d1082d875f509a11891fcfb

config:
  overrides:
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
