# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: make

description: A directory listing program displaying a depth indented list of files

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  make-install: make PREFIX="%{install-root}%{prefix}" MANDIR="%{install-root}%{mandir}" install

sources:
- kind: tar
  url: https://gitlab.com/OldManProgrammer/unix-tree/-/archive/2.3.2/unix-tree-2.3.2.tar.gz
  ref: 513a53cbc42ca1f4ea06af2bab1f5283524a3848266b1d162416f8033afc4985
