# SPDX-FileCopyrightText: 2026 KDE Linux Contributors
# SPDX-License-Identifier: BSD-2-Clause

kind: compose

build-depends:
- kde-buildstream.bst:os/deps.bst
- kde-buildstream.bst:kde.bst

config:
  integrate: False
  include:
  - debug
  include-orphans: False
