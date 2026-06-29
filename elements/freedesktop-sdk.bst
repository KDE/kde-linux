# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: junction

sources:
- kind: git_repo
  url: https://gitlab.com/freedesktop-sdk/freedesktop-sdk.git
  track: master # we need to track master because we bring dependencies from there
  ref: freedesktop-sdk-25.08rc.3-1937-gf90b8f2ba588148c7941b2e26657b8d4f3f04e5c
- kind: patch
  path: files/freedesktop-sdk/libunwind.patch
- kind: patch
  path: files/freedesktop-sdk/json-glib-add-glib-dependency.patch

config:
  options:
    target_arch: '%{arch}'
    (?):
    - arch in ('x86_64', 'i686'):
        bootstrap_build_arch: 'x86_64'
    - arch in ('aarch64', 'arm'):
        bootstrap_build_arch: 'aarch64'
    - arch == "riscv64":
        bootstrap_build_arch: "x86_64"
