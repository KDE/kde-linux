# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: meson

description: Small utility to dump info about DRM devices

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/scdoc.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/json-c.bst
- freedesktop-sdk.bst:components/libdisplay-info.bst
- freedesktop-sdk.bst:components/libdrm.bst
- freedesktop-sdk.bst:components/pciutils.bst

sources:
- kind: tar
  url: https://gitlab.freedesktop.org/emersion/drm_info/-/archive/v2.9.0/drm_info-v2.9.0.tar.gz
  ref: b1000e95eb4f57cfe7819c5b8afd880ac07dde25d9c3839ec52e0aeadeb83234
