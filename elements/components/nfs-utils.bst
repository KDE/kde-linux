# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/nfs-utils/-/raw/main/PKGBUILD?ref_type=heads
kind: autotools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/keyutils.bst
- freedesktop-sdk.bst:components/libnl.bst
- freedesktop-sdk.bst:components/libevent.bst
- freedesktop-sdk.bst:components/libtirpc.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/util-linux.bst
- components/rpcsvc-proto.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/keyutils.bst
- freedesktop-sdk.bst:components/libnl.bst
- freedesktop-sdk.bst:components/libevent.bst
- freedesktop-sdk.bst:components/libtirpc.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/util-linux.bst

variables:
  conf-local: >-
    --disable-gss
    --sbindir=%{bindir}
    --with-rpcgen
  make-install: |
    make -j1 %{make-install-args}
    install -Dm755 "%{install-root}/sbin/mount.nfs" "%{install-root}%{bindir}/mount.nfs"
    install -Dm755 "%{install-root}/sbin/mount.nfs4" "%{install-root}%{bindir}/mount.nfs4"
    install -Dm755 "%{install-root}/sbin/umount.nfs" "%{install-root}%{bindir}/umount.nfs"
    install -Dm755 "%{install-root}/sbin/umount.nfs4" "%{install-root}%{bindir}/umount.nfs4"
    rm -rf "%{install-root}/sbin"

sources:
- kind: tar
  url: https://www.kernel.org/pub/linux/utils/nfs-utils/2.9.1/nfs-utils-2.9.1.tar.xz
  ref: 302846343bf509f8f884c23bdbd0fe853b7f7cbb6572060a9082279d13b21a2c
