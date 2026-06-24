# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: meson

description: D-Bus service to access fingerprint readers

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/perl.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/linux-pam.bst
- freedesktop-sdk.bst:components/polkit-gobject.bst
- freedesktop-sdk.bst:components/systemd.bst
- components/libfprint.bst

sources:
- kind: git_repo
  url: fdo:libfprint/fprintd.git
  track: 'v*'
  ref: v1.94.5-0-gb54a007ccf58ac0ae074c7151b223f35cbd17306
