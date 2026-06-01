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
- qt/qtspeech.bst
- qt/qtsensors.bst
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
  url: qt:6.11/6.11.1/submodules/qtimageformats-everywhere-src-6.11.1.tar.xz
  ref: b2bf6c6845ac175ed7f819145483ba4676f617aaa6a5012c8efee63c8bbac413
