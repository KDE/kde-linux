# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: junction
# There doesn't seem to be branches there so just track master.
# Ideally, we'll move all things we need there to fsdk

sources:
- kind: git_repo
  url: https://gitlab.gnome.org/GNOME/gnome-build-meta.git
  ref: 4c85f037bb88a769c5df9745eab0fe58415c4169

config:
  options:
    arch: '%{arch}'
  overrides:
    freedesktop-sdk.bst: freedesktop-sdk.bst
    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
