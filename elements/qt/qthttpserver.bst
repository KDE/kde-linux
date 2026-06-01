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
- qt/qtimageformats.bst
- qt/qtconnectivity.bst
- qt/qtwayland.bst
- qt/qtserialport.bst
- qt/qtwebsockets.bst
- qt/qtscxml.bst
- qt/qtcharts.bst
- qt/qt3d.bst
- qt/qtnetworkauth.bst
- qt/qttranslations.bst
- qt/qtremoteobjects.bst
- qt/qt5compat.bst
- qt/qtlocation.bst
- qt/qtquicktimeline.bst
- qt/qtquick3d.bst
- qt/qtgraphs.bst
- qt/qtquick3dphysics.bst
- qt/qtquickeffectmaker.bst
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
  url: qt:6.11/6.11.1/submodules/qthttpserver-everywhere-src-6.11.1.tar.xz
  ref: 04bf70fcf76861f9b6870c728085f2375a6b6d923cb5d1a116dff2ed52a4e706
