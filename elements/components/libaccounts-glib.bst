# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: meson

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/gtk-doc.bst
- freedesktop-sdk.bst:components/gobject-introspection.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/pygobject.bst
- freedesktop-sdk.bst:components/vala.bst
- components/libcheck.bst

sources:
- kind: git_repo
  url: https://gitlab.com/accounts-sso/libaccounts-glib
  track: VERSION_*
  ref: VERSION_1.27-0-g26c54322304e9df598b2ba67427433a2e68b823e
