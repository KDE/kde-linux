# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

sources:
- kind: tar
  url: https://cpan.metacpan.org/authors/id/O/OA/OALDERS/URI-5.31.tar.gz
  ref: b9c4d58b2614b8611ae03a95a6d60ed996f4b311ef3cd5a937b92f1825ecc564

depends:
- freedesktop-sdk.bst:sdk.bst
- freedesktop-sdk.bst:components/perl.bst

config:
  configure-commands:
  - perl Makefile.PL PREFIX="%{install-root}%{prefix}" INSTALLDIRS=vendor

  build-commands:
  - make

  install-commands:
  - make install
