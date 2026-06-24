# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: meson

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:components/gobject-introspection.bst
- freedesktop-sdk.bst:components/gtk-doc.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libgudev.bst
- freedesktop-sdk.bst:components/libgusb.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:components/nss.bst
- freedesktop-sdk.bst:components/pixman.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/cairo.bst

sources:
- kind: git_repo
  url: fdo:libfprint/libfprint.git
  track: 'v*'
  ref: v1.94.10-0-g0c97a47d8ef405cd577b87058c1e89cae9d242e7
