# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

description: A utility to resize FAT filesystems using libparted

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/parted.bst

variables:
  conf-local: --sbindir=/usr/bin

sources:
- kind: git_repo
  url: github:ya-mouse/fatresize.git
  track: v1.1.0
  ref: 316981e43b14f42a9aa7b461c97e1f61f6f2390b
