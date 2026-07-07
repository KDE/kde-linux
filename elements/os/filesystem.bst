# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: compose

build-depends:
- kde-linux-packages.bst:kde-buildstream.bst:os/deps.bst
- os/initial-scripts.bst
- os/os-release.bst

config:
  exclude:
  - debug
  - doc
  - tests
  - shells
  include-orphans: True
