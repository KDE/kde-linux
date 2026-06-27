# SPDX-FileCopyrightText: freedesktop-sdk
# SPDX-License-Identifier: MIT

# Fork of libunwind to also install unwind.h

kind: autotools

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  conf-local: >-
    --disable-tests

config:
  install-commands:
    (>):
    - |
      mkdir -p "%{install-root}%{includedir}/%{gcc_triplet}"
      mv "%{install-root}%{includedir}/libunwind.h" "%{install-root}%{includedir}/%{gcc_triplet}/"
      mv "%{install-root}%{includedir}/unwind.h" "%{install-root}%{includedir}/%{gcc_triplet}/"
      for h in "%{install-root}%{includedir}/"libunwind-{x86,arm,aarch64,x86_64,loongarch64}.h; do
        if [ -e "${h}" ]; then
           mv "${h}" "%{install-root}%{includedir}/%{gcc_triplet}/"
        fi
      done

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libunwind*.so'

sources:
- kind: git_repo
  url: github:libunwind/libunwind.git
  track: v*
  exclude:
  - "*-rc*"
  - "*branchpoint*"
  ref: v1.8.3-0-g44aa1a5be2ca68825a17acdf534be4d25cff09b3
