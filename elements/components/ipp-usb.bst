# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/ipp-usb/-/raw/main/PKGBUILD?ref_type=heads
kind: make

description: allows using the IPP protocol, normally designed for network printers, to be used with USB printers as well

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/go.bst
- freedesktop-sdk.bst:components/gzip.bst
- freedesktop-sdk.bst:components/pkg-config.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/avahi.bst
- freedesktop-sdk.bst:components/libusb.bst

variables:
  make-install: |
    make PREFIX="%{install-root}" install
    install -Dm755 "%{install-root}/sbin/ipp-usb" "%{install-root}%{bindir}/ipp-usb"
    rm -rf "%{install-root}/sbin"
    sed -i 's|ExecStart=/sbin/ipp-usb|ExecStart=%{bindir}/ipp-usb|' "%{install-root}/lib/systemd/system/ipp-usb.service"
    mkdir -p "%{install-root}%{prefix}/lib"
    mv "%{install-root}/lib/systemd" "%{install-root}%{prefix}/lib/systemd"
    mv "%{install-root}/lib/udev" "%{install-root}%{prefix}/lib/udev"
    rmdir "%{install-root}/lib"

sources:
- kind: tar
  url: github:OpenPrinting/ipp-usb/archive/0.9.34.tar.gz
  ref: 4f0ada8593fda3f4239a50fcf24a625842143039de97708281e7b8c0cdff201a
