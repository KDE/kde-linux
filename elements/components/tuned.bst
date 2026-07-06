# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: make

description: Daemon that performs monitoring and adaptive configuration of devices in the system

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/systemd.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/gawk.bst
- freedesktop-sdk.bst:components/perf.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/pygobject.bst
- freedesktop-sdk.bst:components/python3-dbus.bst
- freedesktop-sdk.bst:components/python3.bst

runtime-depends:
- components/python-pyudev.bst

variables:
  make-args: >-
    DESTDIR="%{install-root}"
    SBINDIR="%{bindir}"
    LIBEXECDIR="%{indep-libdir}"

  make-install: |
    sed -i 's|/sbin/|/bin/|g' tuned.service tuned-gui.py tuned-gui.desktop tuned/ppd/tuned-ppd.service
    sed -i '/desktop-file-install --dir=/d' Makefile
    make %{make-args} install
    make %{make-args} install-ppd

config:
  install-commands:
    (>):
    - |
      rm -rf "%{install-root}/run" "%{install-root}/var" "%{install-root}%{datadir}/applications"

      python3 -m compileall -o 0 -o 1 -o 2 -d "%{indep-libdir}" "%{install-root}%{indep-libdir}"

sources:
- kind: tar
  url: github:redhat-performance/tuned/archive/v2.27.0/tuned-2.27.0.tar.gz
  ref: 24414ad043f2a75edb803ca8daf8fb93f03d42410f05f744d68d59f09ac2d29d
