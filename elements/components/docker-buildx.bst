# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/docker-buildx/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: Docker CLI plugin for extended build capabilities with BuildKit

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: git_repo
  url: github:docker/buildx.git
  track: 'v*'
  ref: v0.35.0-rc2-0-g73e56595aae0f22dd2b123e092ac3eba28016590
