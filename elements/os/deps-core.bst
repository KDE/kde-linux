# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: stack

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst # base: Base Arch packages; mandatory
- freedesktop-sdk.bst:components/util-linux-full.bst # base: Base Arch packages; mandatory
- freedesktop-sdk.bst:components/linux.bst # linux: It's the kernel!
- freedesktop-sdk.bst:components/linux-firmware.bst
- freedesktop-sdk.bst:components/ca-certificates.bst
- freedesktop-sdk.bst:components/wireless-regdb-bin.bst # wireless-regdb: Gets us the wireless-regdom file that we can modify as needed
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/dracut.bst
- freedesktop-sdk.bst:components/shadow.bst
- freedesktop-sdk.bst:components/tzdata.bst
- freedesktop-sdk.bst:components/udisks.bst
- freedesktop-sdk.bst:vm/mesa-default.bst # mesa: HW enablement for graphics
- freedesktop-sdk.bst:vm/base-filesystem.bst
- freedesktop-sdk.bst:vm/config/journald.bst
- freedesktop-sdk.bst:vm/config/useradd-default.bst
- freedesktop-sdk.bst:vm/config/systemd-homed-firstboot.bst
- freedesktop-sdk.bst:components/hosts.bst
- freedesktop-sdk.bst:components/bash-config.bst
- freedesktop-sdk.bst:components/flatpak.bst # flatpak: Flatpak apps
- freedesktop-sdk.bst:components/plymouth.bst
- freedesktop-sdk.bst:components/sudo.bst
- freedesktop-sdk.bst:components/cups-daemon.bst # cups: Basic printing infrastructure
- freedesktop-sdk.bst:components/cups.bst # cups: Basic printing infrastructure
- freedesktop-sdk.bst:components/alsa-lib.bst
- freedesktop-sdk.bst:components/dosfstools.bst # dosfstools: Manipulating DOS filesystems; used by kpmcore
- freedesktop-sdk.bst:components/btrfs-progs.bst # btrfs-progs: Btrfs tools; so system tools can interact with our disks
- freedesktop-sdk.bst:components/systemd-ukify.bst
- freedesktop-sdk.bst:components/wpa-supplicant.bst
- freedesktop-sdk.bst:components/ccid.bst # ccid: Generic USB CCID/ICCD card readers
- freedesktop-sdk.bst:components/e2fsprogs.bst # e2fsprogs: Manipulating EXT filesystems; used by kpmcore
- freedesktop-sdk.bst:components/erofs-utils.bst # erofs-utils: Erofs tools; so system tools can interact with our OS image
- freedesktop-sdk.bst:components/exfat-progs.bst # exfatprogs: Manipulating exFAT filesystems; used by kpmcore
- freedesktop-sdk.bst:components/f2fs-tools.bst # f2fs-tools: Manipulating f2fs filesystems; used by kpmcore
- freedesktop-sdk.bst:components/foomatic-db.bst # foomatic-db: data about many printers for foomatic-db-engine PPD generator
- freedesktop-sdk.bst:components/fuse3.bst # fuse3: Modern AppImage apps
- freedesktop-sdk.bst:components/iio-sensor-proxy.bst # iio-sensor-proxy: Auto-rotation
- freedesktop-sdk.bst:components/kmod.bst
- freedesktop-sdk.bst:components/lvm2.bst # lvm2: Logical Volume Manager 2 support
- freedesktop-sdk.bst:components/ovmf-maybe.bst # edk2-ovmf: UEFI support for virtual machines
- freedesktop-sdk.bst:components/sbsigntools-maybe.bst # sbsigntools: To sign and verify EFI binaries; needs low-level access to work
- freedesktop-sdk.bst:components/shim-maybe.bst # shim: Sits between firmware and systemd-boot, providing a trusted boot path and support for Secure Boot
- freedesktop-sdk.bst:components/sof-firmware.bst # sof-firmware: Various audio chipsets
- freedesktop-sdk.bst:components/steam-devices.bst # steam-devices: udev rules for devices usable with Steam and SteamVR
- freedesktop-sdk.bst:components/tpm2-tss.bst # tpm2-tss: TPM support
- freedesktop-sdk.bst:components/xdg-user-dirs.bst
- freedesktop-sdk.bst:components/xfsprogs.bst # xfsprogs: Manipulating XFS filesystems; used by kpmcore
- freedesktop-sdk.bst:extensions/vainfo/libva-utils.bst # libva-utils: CLI tools for interacting with and debugging GPU acceleration
- gnome-build-meta.bst:core-deps/sane-backends.bst # sane: scanner udev rules - everything else in the package is deleted later
- gnome-build-meta.bst:gnomeos-deps/android-udev-rules.bst # android-udev: udev rules for accessing Android devices
- gnome-build-meta.bst:gnomeos-deps/mokutil.bst # mokutil: To manage the Machine Owner Key (MOK) list for Shim (only for advanced users); needs low-level access to work
- gnome-build-meta.bst:gnomeos-deps/spice-vdagent.bst # spice-vdagent: QEMU's SPICE counterpart to enable desktop integration (e.g. clipboard sharing, dynamic resolution, etc)
- gnome-build-meta.bst:gnomeos-deps/swtpm.bst # swtpm: TPM emulator used by Incus VMs
- gnome-build-meta.bst:gnomeos-deps/virtiofsd.bst # virtiofsd: Enables access to host folders from virt-manager and incus VMs
- gnome-build-meta.bst:gnomeos-deps/zram-generator.bst # zram-generator: use compressed zram for swap
- components/cups-browsed.bst # cups-browsed: Pre-2012 network printer auto-discovery
- components/ipp-usb.bst # ipp-usb: Connect to post-2012 driverless printers over USB
- components/system-config-printer.bst # system-config-printer: Local printer auto-discovery
- components/fatresize.bst # fatresize: Resizing FAT filesystems; used by kpmcore
- components/gutenprint.bst # gutenprint: FOSS drivers for lots of pre-2012 printers
- components/inotify-tools.bst # inotify-tools: ; for kmscon-launch-gui waiting mechanism
- components/ntfsprogs.bst # ntfsprogs: Manipulating ntfs filesystems; used by kpmcore
- components/powertop.bst # powertop: Energy monitoring; also used in our energy tuning scripts
- components/solaar-udev.bst # solaar: Logitech Unify reciever udev rules - everything else in the package is deleted later
- components/tuned.bst # tuned-ppd: Power profiles
- components/ydotool.bst # ydotool: Basic TUI and GUI app automation; needs low-level access to work
- components/kmscon.bst # kmscon: modern userspace getty and virtual terminal replacement
- components/acsccid.bst # acsccid: ACS CCID smart card readers
- components/bmusb.bst # bmusb: Specialty video capture/playback boxes from BlackMagicDesign
- components/fprintd.bst # fprintd: Fingerprint authentication
- components/pam-u2f.bst # pam-u2f: 2nd factor PAM support for Yubikey hardware authenticators
- components/thermald.bst # thermald: Improved thermal management and performance for Intel CPUs
- components/udev-hid-bpf.bst # udev-hid-bpf: Many drawing tablets
- components/usb_modeswitch.bst # usb_modeswitch: WiFi dongles that have a flash storage mode preventing use OOTB
- gnome-build-meta.bst:core-deps/libusbmuxd.bst # usbmuxd: Apple iOS devices via USB
- components/btrfsmaintenance.bst # btrfsmaintenance: Provides Systemd Services for BTRFS Operations like scrubbing and balancing
- components/efibootmgr.bst # efibootmgr: EFI dump/management tools; needs low-level access to work
- components/open-vm-tools.bst # open-vm-tools: Integration for VMWare virtualization software
- gnome-build-meta.bst:gnomeos-deps/qemu-user.bst # qemu-guest-agent: Integration for QEMU
- components/virtualbox-guest-utils.bst # virtualbox-guest-utils: integration for VirtualBox

(?):
- arch == 'x86_64':
    depends:
      (>):
      - freedesktop-sdk.bst:extensions/platform-vaapi-intel/intel-media-driver.bst # intel-media-driver: Hardware accelerated video on newer Intel GPUs
      #- components/libva-intel-driver.bst # libva-intel-driver: Hardware accelerated video on old Intel GPUs
      - freedesktop-sdk.bst:extensions/platform-vaapi-nvidia/nvidia-vaapi-driver.bst # libva-nvidia-driver: Hardware accelerated video on NVIDIA GPUs
      - components/nvidia-prime.bst # nvidia-prime: prime-run command; used in kio via Dolphin, Plasma, KRunner
      - gnome-build-meta.bst:gnomeos-deps/nvidia-drivers-modules.bst # nvidia-open: Open kernel modules for NVIDIA GPUs
      - gnome-build-meta.bst:gnomeos-deps/nvidia-drivers-libs.bst # nvidia-utils: NVIDIA userspace libraries and Vulkan support
      - gnome-build-meta.bst:gnomeos-deps/intel-ucode.bst
