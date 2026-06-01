# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:sdk.bst

sources:
- kind: tar
  url: https://salsa.debian.org/gnome-team/libcanberra/-/archive/upstream/0.30/libcanberra-upstream-0.30.tar.bz2
  ref: cdceb79c79ce6c56e38fa2075c7fd3a2a5213d65db92483e179eb952a4e138fa
