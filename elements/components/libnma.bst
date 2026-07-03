# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: meson

sources:
- kind: git_repo
  url: gnome:libnma.git
  track: main
  ref: 1.10.7-dev-46-g3b25a43e8e224894dc122594568d2b25edf6b866

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/gobject-introspection.bst
- freedesktop-sdk.bst:components/gtk-doc.bst
- freedesktop-sdk.bst:components/vala.bst

depends:
- freedesktop-sdk.bst:components/networkmanager.bst
- gnome-build-meta.bst:core-deps/mobile-broadband-provider-info.bst
- gnome-build-meta.bst:sdk/gcr.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/gtk3.bst
- freedesktop-sdk.bst:components/iso-codes.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  meson-local: >-
    -Dlibnma_gtk4=true
    -Dvapi=false
