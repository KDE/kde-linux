# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

build-depends:
- freedesktop-sdk.bst:components/findutils.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''
  license-files-extra: LICENSE fonts/LICENSE

config:
  install-commands:
  - |
    install -dm755 "%{install-root}%{datadir}/fonts/noto"
    find fonts -path '*/hinted/ttf/*.tt[fc]' \
      ! -name 'Noto*-Condensed*.ttf' \
      ! -name 'Noto*-Semi*.ttf' \
      ! -name 'Noto*-Extra*.ttf' \
      -exec install -Dm644 -t "%{install-root}%{datadir}/fonts/noto" {} +

sources:
- kind: tar
  url: https://github.com/notofonts/notofonts.github.io/archive/refs/tags/noto-monthly-release-2026.05.01.tar.gz
  ref: 6caa6ea6231842639119d4a9fefd80caed8cd58a49f73d4531b060412005c58d
