# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

# Debug symbols of everything in os/filesystem-compose.bst (which excludes them).
# Cleaned up by os/debug.bst.
kind: compose

build-depends:
- kde-buildstream.bst:os/deps.bst
- kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst

config:
  include:
  - debug
  include-orphans: False
  integrate: False
