# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

description: yaml-cpp C++ YAML parser and emitter library

sources:
  - kind: git
    url: github:dkms-project/dkms.git
    ref: 6e32f352f3d8c7ccbc6fecb05b1517248a2f3934 # 3.3.0 tag
    track: master

build-depends:
  - freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  build-commands:
  - ls
  install-commands:
  - make install DESTDIR="%{install-root}" SBIN=/usr/bin MODDIR=/usr/lib/modules
