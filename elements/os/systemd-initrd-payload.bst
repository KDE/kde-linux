# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: script

build-depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/runtime-gnu.bst
- os/systemd-initrd-compose.bst

variables:
  install-root: /

config:
  commands:
  # de-configure the audit system, we don't need it by default
  - rm --recursive --force /etc/audit/audit.rules # auto generated; may not exist
  - rm --recursive /etc/audit/plugins.d/*
  - rm --recursive /etc/audit/rules.d/*

  # Remove some cruft pulled in by plymouth and friends
  - rm --recursive /usr/share/terminfo
  - rm --recursive /usr/share/misc
  - rm --recursive /usr/share/mime
  - rm --recursive /usr/share/bash-completion

  # There is no need for charset conversion in the initrd. Besides, everything is UTF-8 on KDE Linux anyway.
  - rm --recursive /usr/lib/x86_64-linux-gnu/gconv
