# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:sdk.bst
- qt/qtbase.bst
- qt/qttools.bst
- qt/qtshadertools.bst
- qt/qtlanguageserver.bst
- qt/qtdeclarative.bst
- qt/qtwebchannel.bst
- qt/qtpositioning.bst
- freedesktop-sdk.bst:components/grpc.bst
- qt/qtgrpc.bst
- qt/qtsvg.bst
- qt/qtmultimedia.bst
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
sources:
- kind: tar
  url: qt:6.11/6.11.1/submodules/qtspeech-everywhere-src-6.11.1.tar.xz
  ref: c035c318012025875a653245701a23d3807e8e46b8bf7987877842219c273f14
