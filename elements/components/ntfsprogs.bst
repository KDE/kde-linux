# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: NTFS filesystem driver and utilities

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/gnutls.bst
- freedesktop-sdk.bst:components/libgcrypt.bst
- freedesktop-sdk.bst:components/util-linux.bst

variables:
  conf-local: >-
    --disable-ldconfig
    --disable-static
    --enable-xattr-mappings
    --enable-posix-acls
    --enable-extras
    --enable-crypto
    --mandir=%{mandir}
    --sbindir=/usr/bin

config:
  configure-commands:
    (<):
    - |
      autoreconf -fiv
      sed 's|$(DESTDIR)/sbin|$(DESTDIR)/usr/bin|g' -i {ntfsprogs,src}/Makefile.in
      sed 's|$(DESTDIR)$(sbindir)|$(DESTDIR)/usr/bin|g' -i {ntfsprogs,src}/Makefile.in

  install-commands:
  - |
    make DESTDIR="%{install-root}" \
      rootbindir=/usr/bin \
      rootsbindir=/usr/bin \
      rootlibdir=/usr/lib \
      sbindir=/usr/bin \
      install
  - ln -s /usr/bin/ntfs-3g "%{install-root}/usr/bin/mount.ntfs"

sources:
- kind: git_repo
  url: github:tuxera/ntfs-3g.git
  track: 2026.2.25
  ref: d1cb9e825d059ef5db0ccd30d5bce202edbd69dc
