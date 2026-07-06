# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: stack

depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/pipewire-daemon.bst # pipewire
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/wireplumber.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/xwayland.bst # xorg-xwayland
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/geoclue.bst # geoclue: backend for QtPositioning, used for Night Light automatic location mode
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/libva.bst # libva: Hardware accelerated video in general
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/fwupd.bst # fwupd: for Discover backend
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/rsync.bst # rsync: kup, for one of the backends
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:core-deps/dnsmasq.bst # dnsmasq: Hotspot creation and networking in VMs
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/nss-mdns.bst # nss-mdns: Needed for Avahi mDNS for local domain resolving etc.
- kde-linux-packages.bst:kde-buildstream.bst:components/networkmanager-strongswan.bst # networkmanager-strongswan: VPN support for NetworkManager
- kde-linux-packages.bst:kde-buildstream.bst:components/networkmanager-vpn-plugin-l2tp.bst # networkmanager-vpn-plugin-l2tp: VPN support for NetworkManager
# - gnome-build-meta.bst:gnomeos-deps/NetworkManager-openconnect.bst # networkmanager-vpn-plugin-openconnect: VPN support for NetworkManager
- kde-linux-packages.bst:kde-buildstream.bst:components/networkmanager-vpn-plugin-openvpn.bst # networkmanager-vpn-plugin-openvpn: VPN support for NetworkManager
# - components/networkmanager-vpn-plugin-pptp.bst # networkmanager-vpn-plugin-pptp: VPN support for NetworkManager
- kde-linux-packages.bst:kde-buildstream.bst:components/networkmanager-vpn-plugin-vpnc.bst # networkmanager-vpn-plugin-vpnc: VPN support for NetworkManager
- kde-linux-packages.bst:kde-buildstream.bst:components/nfs-utils.bst # nfs-utils: Support harness for NFS mounting
- kde-linux-packages.bst:kde-buildstream.bst:components/ufw.bst # ufw: Simple firewall; consider switching to firewalld once the KCM supports zones
# - components/pipewire-ffado.bst # pipewire-ffado: FireWire/IEEE 1394 audio
# - components/pipewire-roc.bst # pipewire-roc: ROC streaming
- kde-linux-packages.bst:kde-buildstream.bst:components/appmenu-gtk-module.bst # appmenu-gtk-module: plasma-desktop, for global menu support in GTK 3 apps
- kde-linux-packages.bst:kde-buildstream.bst:components/bup.bst # bup: kup, for one of the backends
- kde-linux-packages.bst:kde-buildstream.bst:components/catdoc.bst # catdoc: kfilemetadata, for indexing old MS word docs
- kde-linux-packages.bst:kde-buildstream.bst:components/jxrlib.bst # jxrlib: kimageformats
# - components/libappimage.bst # libappimage: kio-extras, for AppImage app thumbnails
- kde-linux-packages.bst:kde-buildstream.bst:components/libRaw.bst # libraw: kimageformats
- kde-linux-packages.bst:kde-buildstream.bst:components/lrzip.bst # lrzip: ark, for lzma, rzip, and zpaq compressed archives
- kde-linux-packages.bst:kde-buildstream.bst:components/lzop.bst # lzop: ark, for lzo compressed archives
- kde-linux-packages.bst:kde-buildstream.bst:components/noto-fonts.bst # noto-fonts: Our base font, Noto
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/noto-cjk.bst # noto-fonts-cjk: Noto CJK scripts
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/noto-emoji.bst # noto-fonts-emoji: Noto emojis
- kde-linux-packages.bst:kde-buildstream.bst:components/openexr.bst # openexr: kimageformats
- kde-linux-packages.bst:kde-buildstream.bst:components/opus-tools.bst # opus-tools: audiocd-kio, opus encoding
- kde-linux-packages.bst:kde-buildstream.bst:components/quota-tools.bst # quota-tools: kdeplasma-addons, for Disk Quota widget
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:core-deps/samba.bst # samba: For sharing local folders via Samba
- kde-linux-packages.bst:kde-buildstream.bst:components/switcheroo-control.bst # switcheroo-control: kio, for launching apps on non-default GPU
- kde-linux-packages.bst:kde-buildstream.bst:components/unrar.bst # unrar: ark, for RAR decompression support
- kde-linux-packages.bst:kde-buildstream.bst:components/xdg-desktop-portal-gtk.bst # xdg-desktop-portal-gtk: GTK/Flatpak icon settings syncing
