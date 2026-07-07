# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/dbus-broker/-/raw/main/PKGBUILD?ref_type=heads
kind: meson

description: Linux D-Bus Message Broker

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/systemd.bst

sources:
- kind: tar
  url: github:bus1/dbus-broker/releases/download/v37/dbus-broker-37.tar.xz
  ref: f819a8db8795fa08c767612e3823fd594694a0990f2543ecf35d6a1a6bf2ab5b

config:
  install-commands:
    (>):
    - |
      ln -sf dbus-broker.service "%{install-root}%{indep-libdir}/systemd/system/dbus.service"
      ln -sf dbus-broker.service "%{install-root}%{indep-libdir}/systemd/user/dbus.service"

public:
  bst:
    overlap-whitelist:
    - "%{indep-libdir}/systemd/system/dbus.service"
    - "%{indep-libdir}/systemd/user/dbus.service"
