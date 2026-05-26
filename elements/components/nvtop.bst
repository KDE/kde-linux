# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

description: GPUs process monitoring for AMD, Intel and NVIDIA

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:extensions/mesa/libdrm.bst
- freedesktop-sdk.bst:components/systemd.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:bootstrap/ncurses.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:components/libdrm.bst

environment:
  PKG_CONFIG_PATH: '/usr/lib/%{gcc_triplet}/GL/default/lib/pkgconfig:'

variables:
  cmake-local: >-
    -DNVIDIA_SUPPORT=ON
    -DAMDGPU_SUPPORT=ON
    -DBUILD_TESTING=OFF

sources:
- kind: git_repo
  url: github:Syllo/nvtop.git
  track: 3.3.2
  ref: 76890233d759199f50ad3bdb57a0c0988e96fc44
