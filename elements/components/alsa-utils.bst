# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

sources:
- kind: git_repo
  url: github:alsa-project/alsa-utils.git
  track: v*
  ref: v1.2.16-0-g9feb22ba45b48729729c8d194aaf1bc082a6842a

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/systemd.bst

depends:
- freedesktop-sdk.bst:components/alsa-lib.bst
