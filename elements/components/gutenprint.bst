# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: Top quality printer drivers for POSIX systems

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/cups.bst
- freedesktop-sdk.bst:components/ghostscript.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/cups.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/zlib.bst
- freedesktop-sdk.bst:bootstrap/readline.bst

variables:
  conf-local: >-
    --sbindir=/usr/bin
    --disable-rpath
    --enable-samples
    --disable-static
    --disable-static-genppd
    --enable-cups-ppds
    --enable-simplified-cups-ppds=only
    --enable-translated-cups-ppds
    --enable-globalized-cups-ppds
    --disable-libgutenprintui2

config:
  configure-commands:
    (<):
    - |
      sed -i "s:cups_sbindir=\"\${cups_exec_prefix}\/sbin\":cups_sbindir=\"\${cups_exec_prefix}\/bin\":" m4local/stp_cups.m4
      find -name Makefile.in -exec sed -i 's/$(CURDIR)/BUILDPATH/g' {} +
      autoreconf -vfi

  build-commands:
    (>):
    - |
      sed -i -e 's,Generated at.*,Generated at REDACTED,g' \
             -e 's,uname -a output:.*,uname -a output: REDACTED,g' config.summary
      sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool

sources:
- kind: tar
  url: https://downloads.sourceforge.net/gimp-print/gutenprint-5.3.5.tar.xz
  ref: f5a9f47de28530b1ae2069cfbc647a9a641baeeabe809bb0ef2b3ec5b9668d70
