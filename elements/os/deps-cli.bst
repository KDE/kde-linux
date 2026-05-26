# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: stack

depends:
- freedesktop-sdk.bst:components/iproute2.bst # iproute2: Basic networking tools
- freedesktop-sdk.bst:components/usbutils.bst # usbutils: lsusb and other useful troubleshooting tools
- freedesktop-sdk.bst:components/bash-completion.bst # bash-completion: Completions for Bash
- freedesktop-sdk.bst:components/iputils.bst
- freedesktop-sdk.bst:components/openssh.bst
- freedesktop-sdk.bst:components/openssh-systemd.bst
- freedesktop-sdk.bst:components/vim.bst
- freedesktop-sdk.bst:components/bc.bst # bc: used during kernel builds
- freedesktop-sdk.bst:components/ccache.bst
- freedesktop-sdk.bst:components/cmake.bst
- freedesktop-sdk.bst:components/crun.bst # crun: default for podman
- freedesktop-sdk.bst:components/desktop-file-utils.bst # desktop-file-utils: desktop-file-validate and related useful tools
- freedesktop-sdk.bst:components/flatpak-builder.bst
- freedesktop-sdk.bst:components/git.bst # git: It's git
- freedesktop-sdk.bst:components/git-lfs.bst # git-lfs: Git extension needed for versioning large files
- gnome-build-meta.bst:core-deps/intltool.bst # intltool: make dependency for purpose, plasma-desktop, and kio-gdrive
- freedesktop-sdk.bst:components/jq.bst # jq: JSON processor
- freedesktop-sdk.bst:components/less.bst
- freedesktop-sdk.bst:components/llvm.bst # clang, lld, llvm
- freedesktop-sdk.bst:components/man-db.bst # man-db: Classic `man`
- freedesktop-sdk.bst:components/man-pages.bst # man-pages: Manual pages for things
- freedesktop-sdk.bst:components/meson.bst # meson: often used for glib software as alternative to cmake
- freedesktop-sdk.bst:components/nano.bst
- freedesktop-sdk.bst:components/ninja.bst
- freedesktop-sdk.bst:components/perf.bst
- freedesktop-sdk.bst:components/plocate.bst # plocate: Fast file locating
- freedesktop-sdk.bst:components/podman.bst
- freedesktop-sdk.bst:components/python3-pyyaml.bst # python-yaml: For kde-builder
- freedesktop-sdk.bst:components/ruby.bst # ruby: For the torrent script in the repo
- freedesktop-sdk.bst:components/strace.bst # strace: instrument running executables
- freedesktop-sdk.bst:components/vulkan-icd-loader.bst
- freedesktop-sdk.bst:components/wget2.bst # wget
- components/wireguard-tools.bst # wireguard-tools: CLI tools for controlling WireGuard VPNs
- freedesktop-sdk.bst:components/xz.bst
- freedesktop-sdk.bst:components/zip.bst # zip: the zip CLI archiving tool
- gnome-build-meta.bst:boards/common/alsa-utils.bst # alsa-utils: alsamixer and other useful audio debugging tools
- gnome-build-meta.bst:boards/common/iw.bst # iw: Kernel-level wireless configuration
- gnome-build-meta.bst:core-deps/espeak-ng.bst # espeak-ng: CLI-invoked speech; accessible automation feedback
- gnome-build-meta.bst:gnomeos-deps/distrobox.bst
- components/noto-fonts.bst # noto-fonts: Google Noto TTF fonts
- gnome-build-meta.bst:gnomeos-deps/noto-cjk.bst # noto-fonts-cjk: Noto CJK scripts
- freedesktop-sdk.bst:components/noto-emoji.bst # noto-fonts-emoji: Color emoji font
- gnome-build-meta.bst:gnomeos-deps/nvme-cli.bst # nvme-cli: NVMe SSD support tooling
- gnome-build-meta.bst:gnomeos-deps/toolbox.bst
- gnome-build-meta.bst:gnomeos-deps/wl-clipboard.bst
- gnome-build-meta.bst:gnomeos-deps/words.bst # words: Dictionaries in /usr/share/dict
- gnome-build-meta.bst:sdk-deps/sassc.bst # sassc: make dependency for breeze-gtk and kde-gtk-config
- components/drm-info.bst # drm-info: for debugging KWin and other graphics issues
- components/iotop-c.bst # iotop: Opinionated fancy top for disks
- components/lsof.bst
- components/nvtop.bst # nvtop: Fancy GPU monitoring
- components/tree.bst
- components/xerces-c.bst # xerces-c: optional make dependency for syntax-highlighting
