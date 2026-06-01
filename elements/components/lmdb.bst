# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:sdk.bst

variables:
  autogen: echo "echo $@" > configure; chmod +x configure
  command-subdir: libraries/liblmdb
  make-args: prefix="%{prefix}"
  make-install-args: DESTDIR="%{install-root}" %{make-args} install

sources:
- kind: tar
  url: github:LMDB/lmdb/archive/LMDB_0.9.22.tar.gz
  ref: f3927859882eb608868c8c31586bb7eb84562a40a6bf5cc3e13b6b564641ea28
