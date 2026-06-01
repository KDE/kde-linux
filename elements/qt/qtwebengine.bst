# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:sdk.bst
- qt/qtbase.bst
- qt/qtdeclarative.bst
- qt/qtpositioning.bst
- qt/qtwebchannel.bst
- gnome-build-meta.bst:core-deps/nodejs.bst
- gnome-build-meta.bst:sdk/krb5.bst
- components/python-html5lib.bst
- components/re2.bst

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{prefix}/bin'
        - '%{prefix}/bin/**'

variables:
  cmake-local: >-
    -DQT_FEATURE_webengine_system_icu=ON
    -DQT_FEATURE_webengine_proprietary_codecs=ON
    -DQT_FEATURE_webengine_kerberos=ON
    -DQT_FEATURE_webengine_webrtc_pipewire=ON

    # -DQT_FEATURE_webengine_system_re2=ON
    # -DQT_FEATURE_webengine_system_ffmpeg=ON
    # -DQT_FEATURE_webengine_system_openh264=ON

sources:
- kind: tar
  url: qt:6.11/6.11.1/submodules/qtwebengine-everywhere-src-6.11.1.tar.xz
  ref: 679c66ccc6c158fc215e9c58ef160331ecd29974232e345c05161889f8667083
