# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: junction
# There doesn't seem to be branches there so just track master.
# Ideally, we'll move all things we need there to fsdk

config:
  options:
    arch: '%{arch}'
  overrides:
    freedesktop-sdk.bst: freedesktop-sdk.bst
    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
    sdk/glib.bst: freedesktop-sdk.bst:components/glib.bst
    sdk/vala.bst: freedesktop-sdk.bst:components/vala.bst
    sdk/gtk+-3.bst: freedesktop-sdk.bst:components/gtk3.bst
    core-deps/spice.bst: components/spice.bst
    core-deps/libnma.bst: components/libnma.bst
    gnomeos-deps/openvpn.bst: components/openvpn.bst
    core-deps/NetworkManager.bst: freedesktop-sdk.bst:components/networkmanager.bst
    sdk/at-spi2-core.bst: freedesktop-sdk.bst:components/at-spi2-core.bst
    sdk/cairo.bst: freedesktop-sdk.bst:components/cairo.bst
    sdk/fcitx5-gtk.bst: freedesktop-sdk.bst:components/fcitx5-gtk.bst
    sdk/gcab.bst: freedesktop-sdk.bst:components/gcab.bst
    sdk/gdk-pixbuf.bst: freedesktop-sdk.bst:components/gdk-pixbuf.bst
    sdk/glib-networking.bst: freedesktop-sdk.bst:components/glib-networking.bst
    sdk/gobject-introspection.bst: freedesktop-sdk.bst:components/gobject-introspection.bst
    sdk/graphene.bst: freedesktop-sdk.bst:components/graphene.bst
    sdk/gsettings-desktop-schemas.bst: freedesktop-sdk.bst:components/gsettings-desktop-schemas.bst
    sdk/gtk-doc.bst: freedesktop-sdk.bst:components/gtk-doc.bst
    sdk/json-glib.bst: freedesktop-sdk.bst:components/json-glib.bst
    sdk/libibus.bst: freedesktop-sdk.bst:components/libibus.bst
    sdk/libnotify.bst: freedesktop-sdk.bst:components/libnotify.bst
    sdk/librsvg.bst: freedesktop-sdk.bst:components/librsvg.bst
    sdk/libsecret.bst: freedesktop-sdk.bst:components/libsecret.bst
    sdk/libsoup.bst: freedesktop-sdk.bst:components/libsoup.bst
    sdk/pango.bst: freedesktop-sdk.bst:components/pango.bst
    sdk/pygobject.bst: freedesktop-sdk.bst:components/pygobject.bst


sources:
- kind: git_repo
  url: https://gitlab.gnome.org/GNOME/gnome-build-meta.git
  ref: e7b5e00f44b8ae532d33bcd7f1ca14c2c8dc0a87
