# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:sdk.bst
variables:
  arch-cmake-local: ''
  cmake-local: -DINSTALL_ARCHDATADIR=lib -DQT_CREATE_VERSIONED_HARD_LINK=OFF -DQT_DISABLE_RPATH=ON
    -DBUILD_WITH_PCH=FALSE -DQT_FEATURE_openssl_linked=ON -DQT_FEATURE_system_sqlite=ON
    %{arch-cmake-local}
(?):
- arch == 'x86_64':
    variables:
      arch-cmake-local: -DINSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu
- arch == 'aarch64':
    variables:
      arch-cmake-local: -DINSTALL_LIBDIR=/usr/lib/aarch64-linux-gnu
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
  url: qt:6.11/6.11.1/submodules/qtbase-everywhere-src-6.11.1.tar.xz
  ref: d9594a31228aa23ad6b531719a29b45f0f3989fe6c136d45767ea179f233c1ac
- kind: patch
  path: elements/qt/patch/qtbase-find_package-paths.patch
- kind: patch
  path: elements/qt/patch/qtbase-use-adwaita-decorations-on-gnome-by-default.patch
