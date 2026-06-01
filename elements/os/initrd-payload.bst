# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

build-depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

environment:
  INSTALL_ROOT: '%{install-root}'

config:
  install-commands:
  - |
    install -d "$INSTALL_ROOT/usr/lib"
    install -d "$INSTALL_ROOT/usr/lib/udev/rules.d"
    install -d "$INSTALL_ROOT/usr/lib/systemd/system-generators"
    install -d "$INSTALL_ROOT/usr/lib/systemd/system/local-fs-pre.target.wants"
    cp -a mkosi-extra-src/usr/lib/rootfs-transition "$INSTALL_ROOT/usr/lib/rootfs-transition"
    cp -a mkosi-extra-src/usr/lib/btrfs-migrator "$INSTALL_ROOT/usr/lib/btrfs-migrator"
    cp -a mkosi-extra-src/usr/lib/etc-factory "$INSTALL_ROOT/usr/lib/etc-factory"
    cp -a mkosi-extra-src/usr/lib/systemd/system-generators/kde-linux-live-generator "$INSTALL_ROOT/usr/lib/systemd/system-generators/kde-linux-live-generator"
    cp -a mkosi-extra-src/usr/lib/systemd/system-generators/kde-linux-mount-generator "$INSTALL_ROOT/usr/lib/systemd/system-generators/kde-linux-mount-generator"
    cp -a mkosi-extra-src/usr/lib/systemd/system/etc-factory.service "$INSTALL_ROOT/usr/lib/systemd/system/etc-factory.service"
    cp -a mkosi-extra-src/usr/lib/systemd/system/local-fs-pre.target.wants/etc-factory.service "$INSTALL_ROOT/usr/lib/systemd/system/local-fs-pre.target.wants/etc-factory.service"

sources:
- kind: local
  path: mkosi.extra
  directory: mkosi-extra-src
