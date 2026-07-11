# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: manual

build-depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:bootstrap/stripper.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/binutils.bst # for objdump

depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/btrfs-progs.bst # runtime dep of btrfs stuff

config:
  install-commands:
  - |
    install -d "%{install-root}/usr/lib"
    install -d "%{install-root}/usr/lib/udev/rules.d"
    install -d "%{install-root}/usr/lib/systemd/system-generators"
    install -d "%{install-root}/usr/lib/systemd/system/local-fs-pre.target.wants"
    cp -a mkosi-extra-src/usr/lib/rootfs-transition "%{install-root}/usr/lib/rootfs-transition"
    cp -a mkosi-extra-src/usr/lib/btrfs-migrator "%{install-root}/usr/lib/btrfs-migrator"
    cp -a mkosi-extra-src/usr/lib/etc-factory "%{install-root}/usr/lib/etc-factory"
    cp -a mkosi-extra-src/usr/lib/systemd/system-generators/kde-linux-live-generator "%{install-root}/usr/lib/systemd/system-generators/kde-linux-live-generator"
    cp -a mkosi-extra-src/usr/lib/systemd/system-generators/kde-linux-mount-generator "%{install-root}/usr/lib/systemd/system-generators/kde-linux-mount-generator"
    cp -a mkosi-extra-src/usr/lib/systemd/system/etc-factory.service "%{install-root}/usr/lib/systemd/system/etc-factory.service"
    cp -a mkosi-extra-src/usr/lib/systemd/system/local-fs-pre.target.wants/etc-factory.service "%{install-root}/usr/lib/systemd/system/local-fs-pre.target.wants/etc-factory.service"

sources:
- kind: local
  path: mkosi.extra
  directory: mkosi-extra-src
