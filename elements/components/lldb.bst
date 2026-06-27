# SPDX-FileCopyrightText: 2017 freedesktop-sdk
# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: MIT

# Inspired by ArchLinux's PKGBUILD:

kind: cmake

(@):
- freedesktop-sdk.bst:elements/include/llvm.yml

build-depends:
- freedesktop-sdk.bst:components/_private/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/_private/python3-minimal.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libffi.bst
- freedesktop-sdk.bst:components/zlib.bst
- freedesktop-sdk.bst:components/zstd.bst
- freedesktop-sdk.bst:components/llvm.bst

environment:
  # Work-around issue building compiler-rt with multiarch
  LD_LIBRARY_PATH: '%{build-root}/%{build-dir}/lib/%{gcc_triplet}'

variables:
  conf-root: lldb

  debug_flags: "-g1"
  optimize-debug: "false"

  cmake-local: >-
    -DLLVM_DIR='%{libdir}/cmake/llvm'
    -DClang_DIR='%{libdir}/cmake/clang'
    -DCMAKE_SKIP_RPATH=ON
    -DCLANG_LINK_CLANG_DYLIB=ON
    -DLLVM_LINK_LLVM_DYLIB=ON
    -DLLVM_INCLUDE_TESTS=OFF
    -DLLDB_INCLUDE_TESTS=OFF

sources:
  (>):
  - kind: patch
    path: files/lldb/lldb-standalone-clang-resource-dir.patch
