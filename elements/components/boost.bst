# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

build-depends:
- freedesktop-sdk.bst:sdk.bst

config:
  install-commands:
  - ./bootstrap.sh --prefix=%{install-root}/usr --with-libraries=filesystem,system,program_options,iostreams,container
  - ./b2 headers
  - ./b2 install

sources:
- kind: tar
  url: https://archives.boost.io/release/1.89.0/source/boost_1_89_0.tar.bz2
  ref: 85a33fa22621b4f314f8e85e1a5e2a9363d22e4f4992925d4bb3bc631b5a0c7a
