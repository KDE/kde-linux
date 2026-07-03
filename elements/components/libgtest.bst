# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

sources:
- kind: git_repo
  url: github:google/googletest.git
  track: 'v*'
  ref: v1.17.0-0-g52eb8108c5bdec04579160ae17225d66034bd723

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
