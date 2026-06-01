# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: cmake

sources:
- kind: git_repo
  url: github:freerdp/freerdp.git
  track: '*.*.*'
  ref: 3.26.0-0-g3f6d7cb1f8973cc84c66b258a9a61c4e2b2f30a6

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- gnome-build-meta.bst:sdk/krb5.bst
- freedesktop-sdk.bst:components/cups.bst
- freedesktop-sdk.bst:components/ffmpeg.bst
- freedesktop-sdk.bst:components/jansson.bst
- freedesktop-sdk.bst:components/libpulse.bst
- freedesktop-sdk.bst:components/libusb.bst
- freedesktop-sdk.bst:components/openjpeg.bst
- freedesktop-sdk.bst:components/openssl.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

# CLIENT_SDL depends on webkit2gtk-4.0.
variables:
  cmake-local: >-
    -DRDTK_FORCE_STATIC_BUILD=ON
    -DUWAC_FORCE_STATIC_BUILD=ON
    -DWITH_ADD=ON
    -DWITH_BINARY_VERSIONING=ON
    -DWITH_CHANNELS=ON
    -DWITH_CLIENT_CHANNELS=ON
    -DWITH_CUPS=ON
    -DWITH_DSP_FFMPEG=ON
    -DWITH_FFMPEG=ON
    -DWITH_JANSSON_REQUIRED=ON
    -DWITH_JPEG=ON
    -DWITH_MANPAGES=ON
    -DWITH_PCSC=ON
    -DWITH_PKCS11=ON
    -DWITH_PULSE=ON
    -DWITH_SERVER_CHANNELS=ON
    -DWITH_SERVER=ON
    -DPKG_CONFIG_RELOCATABLE=OFF
    -DWITH_ALSA=OFF
    -DWITH_CLIENT_SDL=OFF
    -DWITH_FUSE=OFF
    -DWITH_SAMPLE=OFF
    -DWITH_X11=OFF
