# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: script

build-depends:
- os/filesystem-compose.bst

variables:
  install-root: /

config:
  commands:
  # de-configure the audit system, we don't need it by default
  - rm --recursive --force /etc/audit/audit.rules # auto generated; may not exist
  - rm --recursive /etc/audit/plugins.d/*
  - rm --recursive /etc/audit/rules.d/*
  # Don't need the uncompressed kernel
  - rm /usr/lib/modules/*/vmlinux
  # Drop some static libs.
  # Be very careful with what you add here.
  # Some things are actually needed to build stuff! (notably some gcc .a files)
  - rm /usr/lib/x86_64-linux-gnu/libQt*.a
  - rm /usr/lib/x86_64-linux-gnu/libqpdf.a
  # Don't need the thesaurus, we have no framework or app to consume them. And they are huge!
  - rm --recursive /usr/share/locale/*/mythes
  - rm --recursive /usr/share/mythes
  # Same for hyphen, a hyphenation library of hunspell
  - rm --recursive /usr/share/locale/*/hyphen
  # Don't need hunspell either, we consume them from the flatpak runtime
  - rm --recursive /usr/share/locale/*/hunspell
  # Definitely don't need installed tests
  - rm --recursive /usr/share/installed-tests
  # GTK Demo stuff
  - rm /usr/bin/gtk*-demo*
  - rm /usr/share/applications/gtk3*.desktop
  - rm /usr/share/applications/org.gtk.*.desktop
  # Excessive vim leakage
  - rm /usr/share/applications/gvim.desktop
  # Debug utils. Super large and probably not useful 99.999999% of the time
  - rm /usr/bin/lto-dump
  - rm /usr/bin/llvm-exegesis
