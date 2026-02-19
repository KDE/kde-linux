# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: compose

build-depends:
- os/deps.bst
- os/initial-scripts.bst

config:
  exclude:
  - debug
  - doc
  - tests
  - shells
  include-orphans: True
