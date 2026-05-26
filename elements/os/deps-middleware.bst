# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: stack

depends:
- freedesktop-sdk.bst:components/pipewire-daemon.bst # pipewire
- freedesktop-sdk.bst:components/wireplumber.bst
- freedesktop-sdk.bst:components/xwayland.bst # xorg-xwayland
- freedesktop-sdk.bst:components/geoclue.bst # geoclue: backend for QtPositioning, used for Night Light automatic location mode
- freedesktop-sdk.bst:components/libva.bst # libva: Hardware accelerated video in general
- freedesktop-sdk.bst:components/fwupd.bst # fwupd: for Discover backend
- freedesktop-sdk.bst:components/rsync.bst # rsync: kup, for one of the backends
- gnome-build-meta.bst:core-deps/dnsmasq.bst # dnsmasq: Hotspot creation and networking in VMs
# - gnome-build-meta.bst:core-deps/qemu.bst # qemu-desktop: virtual machines with GTK, SDL, SPICE, USB redirection, and virgl
# - gnome-build-meta.bst:gnomeos-deps/NetworkManager-openconnect.bst # networkmanager-vpn-plugin-openconnect
# - gnome-build-meta.bst:gnomeos-deps/NetworkManager-openvpn.bst # networkmanager-vpn-plugin-openvpn
# - gnome-build-meta.bst:gnomeos-deps/NetworkManager-vpnc.bst # networkmanager-vpn-plugin-vpnc
- gnome-build-meta.bst:gnomeos-deps/nss-mdns.bst # nss-mdns: Needed for Avahi mDNS for local domain resolving etc.
- components/libRaw.bst # libraw: kimageformats
- components/lrzip.bst # lrzip: ark, for lzma, rzip, and zpaq compressed archives
- components/lzop.bst # lzop: ark, for lzo compressed archives
- components/samba.bst # samba: For sharing local folders via Samba
# - gnome-build-meta.bst:gnomeos-deps/switcheroo-control.bst # switcheroo-control: kio, for launching apps on non-default GPU
# - gnome-build-meta.bst:core/xdg-desktop-portal-gtk.bst # xdg-desktop-portal-gtk: GTK/Flatpak icon settings syncing
