# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/avahi.bst
- freedesktop-sdk.bst:components/cups.bst
- freedesktop-sdk.bst:components/libcupsfilters.bst
- freedesktop-sdk.bst:components/libppd.bst

sources:
- kind: git_repo
  url: github:OpenPrinting/cups-browsed
  ref: 2.1.1-0-g089450357e61673fa9871b927c4b3b6cea4690a1
  track: '*.*.*'
