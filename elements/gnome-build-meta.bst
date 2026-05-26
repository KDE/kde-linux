# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: junction
# There doesn't seem to be branches there so just track master.
# Ideally, we'll move all things we need there to fsdk

sources:
- kind: git_repo
  url: https://gitlab.gnome.org/GNOME/gnome-build-meta.git
  ref: e7b5e00f44b8ae532d33bcd7f1ca14c2c8dc0a87

config:
  options:
    arch: '%{arch}'
  overrides:
    freedesktop-sdk.bst: freedesktop-sdk.bst
    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
