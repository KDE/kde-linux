# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: stack

depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-python.bst
- freedesktop-sdk.bst:sdk.bst
- freedesktop-sdk.bst:components/python3-lxml.bst
- freedesktop-sdk.bst:components/python3-sphinx.bst
- freedesktop-sdk.bst:components/docbook-xml.bst
- freedesktop-sdk.bst:components/docbook-xsl.bst
- freedesktop-sdk.bst:components/networkmanager.bst
- freedesktop-sdk.bst:components/modemmanager.bst
- freedesktop-sdk.bst:components/linux-pam-base.bst
- freedesktop-sdk.bst:components/polkit.bst
- freedesktop-sdk.bst:components/polkit-gobject.bst
- freedesktop-sdk.bst:components/grpc.bst
- freedesktop-sdk.bst:components/xwayland.bst
- freedesktop-sdk.bst:components/gpgmepp.bst
- freedesktop-sdk.bst:components/libndp.bst
- freedesktop-sdk.bst:components/rust.bst
- freedesktop-sdk.bst:components/libnl.bst
- freedesktop-sdk.bst:components/libei.bst
- freedesktop-sdk.bst:components/libdisplay-info.bst
- freedesktop-sdk.bst:components/libevdev.bst
- freedesktop-sdk.bst:components/libinput.bst
- freedesktop-sdk.bst:components/mtdev.bst
- freedesktop-sdk.bst:components/python3-jinja2.bst
- freedesktop-sdk.bst:components/python3-psutil.bst # drkonqi
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:components/git.bst
- freedesktop-sdk.bst:components/elfutils.bst # heaptrack
- freedesktop-sdk.bst:components/libunwind.bst # heaptrack -- FIXME need to fix upstream in freedesktop-sdk. this is a temporary fork!
- os/deps-core.bst
- os/deps-middleware.bst
- os/deps-apps.bst
- os/deps-cli.bst
- components/lm-sensors.bst
- components/tesseract.bst # Spectacle OCR
- gnome-build-meta.bst:core-deps/libgit2.bst # kup
- components/libssh.bst # konsole
- components/freerdp.bst # krdp
- components/boost.bst
- components/exiv2.bst
- components/corrosion.bst
- components/lmdb.bst # baloo
- components/libaccounts-glib.bst
- components/libstemmer.bst
- components/canberra.bst
- components/perl-uri-escape.bst
- components/opencv.bst # spectacle
- components/qrencode.bst # prison
- components/libdmtx.bst # prison
- components/zxing.bst # prison
- components/pygdbmi.bst # drkonqi
- components/python3-sentry-sdk.bst # drkonqi
- components/py-setproctitle.bst
- components/qcoro.bst # konsole
- qt.bst

# KDE Linux needs GCC and such installed so that it can build calamares
- components/yamlcpp.bst
