# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: stack

depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/runtime-minimal.bst # base: Base Arch packages; mandatory
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/util-linux-full.bst # base: Base Arch packages; mandatory
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/linux.bst # linux: It's the kernel!
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/linux-firmware.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/ca-certificates.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/wireless-regdb-bin.bst # wireless-regdb: Gets us the wireless-regdom file that we can modify as needed
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/systemd.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/dbus.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/dracut.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/shadow.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/tzdata.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/udisks.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:vm/mesa-default.bst # mesa: HW enablement for graphics
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:vm/base-filesystem.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:vm/config/journald.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:vm/config/useradd-default.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:vm/config/systemd-homed-firstboot.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/hosts.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/bash-config.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/flatpak.bst # flatpak: Flatpak apps
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/plymouth.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/sudo.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/cups-daemon.bst # cups: Basic printing infrastructure
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/cups.bst # cups: Basic printing infrastructure
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/alsa-lib.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/dosfstools.bst # dosfstools: Manipulating DOS filesystems; used by kpmcore
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/btrfs-progs.bst # btrfs-progs: Btrfs tools; so system tools can interact with our disks
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/systemd-ukify.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/wpa-supplicant.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/ccid.bst # ccid: Generic USB CCID/ICCD card readers
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/e2fsprogs.bst # e2fsprogs: Manipulating EXT filesystems; used by kpmcore
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/erofs-utils.bst # erofs-utils: Erofs tools; so system tools can interact with our OS image
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/exfat-progs.bst # exfatprogs: Manipulating exFAT filesystems; used by kpmcore
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/f2fs-tools.bst # f2fs-tools: Manipulating f2fs filesystems; used by kpmcore
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/foomatic-db.bst # foomatic-db: data about many printers for foomatic-db-engine PPD generator
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/fuse3.bst # fuse3: Modern AppImage apps
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/iio-sensor-proxy.bst # iio-sensor-proxy: Auto-rotation
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/kmod.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/lvm2.bst # lvm2: Logical Volume Manager 2 support
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/ovmf-maybe.bst # edk2-ovmf: UEFI support for virtual machines
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/sbsigntools-maybe.bst # sbsigntools: To sign and verify EFI binaries; needs low-level access to work
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/shim-maybe.bst # shim: Sits between firmware and systemd-boot, providing a trusted boot path and support for Secure Boot
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/sof-firmware.bst # sof-firmware: Various audio chipsets
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/steam-devices.bst # steam-devices: udev rules for devices usable with Steam and SteamVR
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/tpm2-tss.bst # tpm2-tss: TPM support
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/xdg-user-dirs.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/xfsprogs.bst # xfsprogs: Manipulating XFS filesystems; used by kpmcore
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:extensions/vainfo/libva-utils.bst # libva-utils: CLI tools for interacting with and debugging GPU acceleration
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:core-deps/sane-backends.bst # sane: scanner udev rules - everything else in the package is deleted later
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/android-udev-rules.bst # android-udev: udev rules for accessing Android devices
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/mokutil.bst # mokutil: To manage the Machine Owner Key (MOK) list for Shim (only for advanced users); needs low-level access to work
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/spice-vdagent.bst # spice-vdagent: QEMU's SPICE counterpart to enable desktop integration (e.g. clipboard sharing, dynamic resolution, etc)
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/swtpm.bst # swtpm: TPM emulator used by Incus VMs
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/virtiofsd.bst # virtiofsd: Enables access to host folders from virt-manager and incus VMs
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/zram-generator.bst # zram-generator: use compressed zram for swap
- kde-linux-packages.bst:kde-buildstream.bst:components/cups-browsed.bst # cups-browsed: Pre-2012 network printer auto-discovery
- kde-linux-packages.bst:kde-buildstream.bst:components/ipp-usb.bst # ipp-usb: Connect to post-2012 driverless printers over USB
- kde-linux-packages.bst:kde-buildstream.bst:components/system-config-printer.bst # system-config-printer: Local printer auto-discovery
- kde-linux-packages.bst:kde-buildstream.bst:components/fatresize.bst # fatresize: Resizing FAT filesystems; used by kpmcore
- kde-linux-packages.bst:kde-buildstream.bst:components/gutenprint.bst # gutenprint: FOSS drivers for lots of pre-2012 printers
- kde-linux-packages.bst:kde-buildstream.bst:components/inotify-tools.bst # inotify-tools: ; for kmscon-launch-gui waiting mechanism
- kde-linux-packages.bst:kde-buildstream.bst:components/ntfsprogs.bst # ntfsprogs: Manipulating ntfs filesystems; used by kpmcore
- kde-linux-packages.bst:kde-buildstream.bst:components/powertop.bst # powertop: Energy monitoring; also used in our energy tuning scripts
- kde-linux-packages.bst:kde-buildstream.bst:components/solaar-udev.bst # solaar: Logitech Unify reciever udev rules - everything else in the package is deleted later
- kde-linux-packages.bst:kde-buildstream.bst:components/tuned.bst # tuned-ppd: Power profiles
- kde-linux-packages.bst:kde-buildstream.bst:components/ydotool.bst # ydotool: Basic TUI and GUI app automation; needs low-level access to work
- kde-linux-packages.bst:kde-buildstream.bst:components/kmscon.bst # kmscon: modern userspace getty and virtual terminal replacement
- kde-linux-packages.bst:kde-buildstream.bst:components/acsccid.bst # acsccid: ACS CCID smart card readers
- kde-linux-packages.bst:kde-buildstream.bst:components/bmusb.bst # bmusb: Specialty video capture/playback boxes from BlackMagicDesign
- kde-linux-packages.bst:kde-buildstream.bst:components/fprintd.bst # fprintd: Fingerprint authentication
- kde-linux-packages.bst:kde-buildstream.bst:components/pam-u2f.bst # pam-u2f: 2nd factor PAM support for Yubikey hardware authenticators
- kde-linux-packages.bst:kde-buildstream.bst:components/thermald.bst # thermald: Improved thermal management and performance for Intel CPUs
- kde-linux-packages.bst:kde-buildstream.bst:components/udev-hid-bpf.bst # udev-hid-bpf: Many drawing tablets
- kde-linux-packages.bst:kde-buildstream.bst:components/usb_modeswitch.bst # usb_modeswitch: WiFi dongles that have a flash storage mode preventing use OOTB
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:core-deps/libusbmuxd.bst # usbmuxd: Apple iOS devices via USB
- kde-linux-packages.bst:kde-buildstream.bst:components/btrfsmaintenance.bst # btrfsmaintenance: Provides Systemd Services for BTRFS Operations like scrubbing and balancing
- kde-linux-packages.bst:kde-buildstream.bst:components/efibootmgr.bst # efibootmgr: EFI dump/management tools; needs low-level access to work
- kde-linux-packages.bst:kde-buildstream.bst:components/open-vm-tools.bst # open-vm-tools: Integration for VMWare virtualization software
- kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/qemu-user.bst # qemu-guest-agent: Integration for QEMU
- kde-linux-packages.bst:kde-buildstream.bst:components/virtualbox-guest-utils.bst # virtualbox-guest-utils: integration for VirtualBox

(?):
- arch == 'x86_64':
    depends:
      (>):
      - kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:extensions/platform-vaapi-intel/intel-media-driver.bst # intel-media-driver: Hardware accelerated video on newer Intel GPUs
      #- components/libva-intel-driver.bst # libva-intel-driver: Hardware accelerated video on old Intel GPUs
      - kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:extensions/platform-vaapi-nvidia/nvidia-vaapi-driver.bst # libva-nvidia-driver: Hardware accelerated video on NVIDIA GPUs
      - kde-linux-packages.bst:kde-buildstream.bst:components/nvidia-prime.bst # nvidia-prime: prime-run command; used in kio via Dolphin, Plasma, KRunner
      - kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/nvidia-drivers-modules.bst # nvidia-open: Open kernel modules for NVIDIA GPUs
      - kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/nvidia-drivers-libs.bst # nvidia-utils: NVIDIA userspace libraries and Vulkan support
      - kde-linux-packages.bst:kde-buildstream.bst:gnome-build-meta.bst:gnomeos-deps/intel-ucode.bst
