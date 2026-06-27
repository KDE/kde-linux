# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: autotools

sources:
- kind: git_repo
  url: github:OpenVPN/openvpn.git
  track: 'v*'
  exclude:
  - '*rc*'
  - '*beta*'
  - '*alpha*'
  ref: v2.7.4-0-g8e9e91f4caff9a80961f32a1f9eda7e5a489176e

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst
- freedesktop-sdk.bst:components/git.bst
- freedesktop-sdk.bst:components/python3-docutils.bst

depends:
- freedesktop-sdk.bst:components/libcap-ng.bst
- freedesktop-sdk.bst:components/libnl.bst
- freedesktop-sdk.bst:components/linux-pam.bst
- freedesktop-sdk.bst:components/lz4.bst
- freedesktop-sdk.bst:components/lzo.bst
- freedesktop-sdk.bst:components/openssl.bst
