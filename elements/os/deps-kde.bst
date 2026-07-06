# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: stack

depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/buildsystem-python.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:sdk.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/python3-lxml.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/python3-sphinx.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/docbook-xml.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/docbook-xsl.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/networkmanager.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/modemmanager.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/linux-pam-base.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/polkit.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/polkit-gobject.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/grpc.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/xwayland.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/gpgmepp.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/libndp.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/rust.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/libnl.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/libei.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/libdisplay-info.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/libevdev.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/libinput.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/mtdev.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/python3-jinja2.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/python3-psutil.bst # drkonqi
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/python3.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/git.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/elfutils.bst # heaptrack
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/libunwind.bst # heaptrack -- FIXME need to fix upstream in freedesktop-sdk. this is a temporary fork!
- os/deps-core.bst
- os/deps-middleware.bst
- os/deps-apps.bst
- os/deps-cli.bst
- kde-linux-packages.bst:kde-buildstream.bst:components/lm-sensors.bst
- kde-linux-packages.bst:kde-buildstream.bst:components/tesseract.bst # Spectacle OCR
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:core-deps/libgit2.bst # kup
- kde-linux-packages.bst:kde-buildstream.bst:components/libssh.bst # konsole
- kde-linux-packages.bst:kde-buildstream.bst:components/freerdp.bst # krdp
- kde-linux-packages.bst:kde-buildstream.bst:components/boost.bst
- kde-linux-packages.bst:kde-buildstream.bst:components/exiv2.bst
- kde-linux-packages.bst:kde-buildstream.bst:components/corrosion.bst
- kde-linux-packages.bst:kde-buildstream.bst:components/lmdb.bst # baloo
- kde-linux-packages.bst:kde-buildstream.bst:components/libaccounts-glib.bst
- kde-linux-packages.bst:kde-buildstream.bst:components/libstemmer.bst
- kde-linux-packages.bst:kde-buildstream.bst:components/canberra.bst
- kde-linux-packages.bst:kde-buildstream.bst:components/perl-uri-escape.bst
- kde-linux-packages.bst:kde-buildstream.bst:components/opencv.bst # spectacle
- kde-linux-packages.bst:kde-buildstream.bst:components/qrencode.bst # prison
- kde-linux-packages.bst:kde-buildstream.bst:components/libdmtx.bst # prison
- kde-linux-packages.bst:kde-buildstream.bst:components/zxing.bst # prison
- kde-linux-packages.bst:kde-buildstream.bst:components/pygdbmi.bst # drkonqi
- kde-linux-packages.bst:kde-buildstream.bst:components/python3-sentry-sdk.bst # drkonqi
- kde-linux-packages.bst:kde-buildstream.bst:components/py-setproctitle.bst
- kde-linux-packages.bst:kde-buildstream.bst:components/qcoro.bst # konsole
- kde-linux-packages.bst:kde-buildstream.bst:qt.bst

# KDE Linux needs GCC and such installed so that it can build calamares
- kde-linux-packages.bst:kde-buildstream.bst:components/yamlcpp.bst
