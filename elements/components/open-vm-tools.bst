# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/open-vm-tools/-/raw/main/PKGBUILD?ref_type=heads
kind: autotools

description: The Open Virtual Machine Tools (open-vm-tools) are the open source implementation of VMware Tools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- components/libmspack.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:bootstrap/libxcrypt.bst
- freedesktop-sdk.bst:components/fuse3.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/grpc.bst
- freedesktop-sdk.bst:components/icu.bst
- freedesktop-sdk.bst:components/iproute2.bst
- freedesktop-sdk.bst:components/libtirpc.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/linux-pam.bst
- freedesktop-sdk.bst:components/procps.bst
- components/re2.bst
- components/rpcsvc-proto.bst
- components/xmlsec.bst

variables:
  command-subdir: open-vm-tools
  conf-args: >-
    --prefix=%{prefix}
    --libdir=%{libdir}
    --with-udev-rules-dir=/usr/lib/udev/rules.d
    --without-kernel-modules
    --without-x

sources:
- kind: git_repo
  url: github:vmware/open-vm-tools
  track: 'stable-*'
  ref: stable-13.1.0-0-g50cede15e10a21ab919f5ad2961ae0a1840a1911
