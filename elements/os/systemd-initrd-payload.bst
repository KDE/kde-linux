# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: script

build-depends:
- os/systemd-initrd-compose.bst
- os/systemd-initrd-mkosi-extra.bst

variables:
  install-root: /

config:
  commands:
  - rm -r /etc/audit # de-configure the audit system, we don't need it by default
  # It'd be nice to keep the firmwares but unfortunately they are just too large for the initrd
  - mv /lib/firmware /tmp/firmware
  - mkdir /lib/firmware
  - mv -v /tmp/firmware/*ucode* /lib/firmware/
