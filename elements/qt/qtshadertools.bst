# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:sdk.bst
- qt/qtbase.bst
- qt/qttools.bst
environment:
  INSTALL_ROOT: '%{install-root}'
  FLATPAK_DEST: '%{prefix}'
public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{prefix}/bin'
        - '%{prefix}/bin/**'
        - '**/lib/plugins/qmltooling'
        - '**/lib/plugins/qmltooling/**'
sources:
- kind: tar
  url: qt:6.11/6.11.1/submodules/qtshadertools-everywhere-src-6.11.1.tar.xz
  ref: 2075052f9b23bcf9de045bbd180037084942f82cce870aab14a1454902c982fc
