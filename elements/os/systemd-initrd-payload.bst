# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: script

build-depends:
- os/systemd-initrd-compose.bst

variables:
  install-root: /

config:
  commands:
  - rm -r /etc/audit # de-configure the audit system, we don't need it by default

  # Remove some cruft pulled in by plymouth and friends
  - rm -r /usr/share/terminfo
  - rm -r /usr/share/misc
  - rm -r /usr/share/mime
  - rm -r /usr/share/bash-completion
