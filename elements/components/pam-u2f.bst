# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/pam-u2f/-/raw/main/PKGBUILD?ref_type=heads
kind: cmake

description: Universal 2nd Factor (U2F) PAM authentication module from Yubico

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/asciidoc.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libfido2.bst
- freedesktop-sdk.bst:components/linux-pam.bst
- freedesktop-sdk.bst:components/systemd.bst

sources:
- kind: git_repo
  url: github:Yubico/pam-u2f.git
  track: '*'
  ref: pam_u2f-1.4.0-0-g1d85db26b590c191a508d06eddc86fbff6b5009e
