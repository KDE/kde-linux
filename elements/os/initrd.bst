# SPDX-FileCopyrightText: 2026 Aleix Pol <aleixpol@kde.org>
#
# SPDX-License-Identifier: BSD-2-Clause

kind: script

build-depends:
- freedesktop-sdk.bst:components/fakecap.bst
- freedesktop-sdk.bst:components/btrfs-progs.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/dracut.bst
- freedesktop-sdk.bst:components/shadow.bst
- freedesktop-sdk.bst:components/systemd.bst
- freedesktop-sdk.bst:components/tzdata.bst
- freedesktop-sdk.bst:vm/boot/efi/deps.bst
- freedesktop-sdk.bst:vm/boot/efi/initial-scripts.bst
- freedesktop-sdk.bst:vm/prepare-image.bst
- os/initrd-payload.bst
- os/os-release.bst

variables:
  # A stable UUID namespace used by prepare-image.sh to derive reproducible root/EFI UUIDs and password salt.
  uuidnamespace: df2427db-01ec-4c99-96b1-be3edb3cd9f6
  # build.sh checks this artifact out into BUILDSTREAM_BOOTFS and mounts it at /boot
  install-root: /boot

environment:
  LD_PRELOAD: /usr/libexec/fakecap/fakecap.so
  FAKECAP_DB: /fakecap

config:
  commands:
  - mkdir -p /fakecap
  - mkdir -p /tmp
  - mkdir -p /var/tmp
  - mkdir -p /boot
  - prepare-image.sh --sysroot / --rootpasswd root --seed "%{uuidnamespace}" >/tmp/vars
  - echo '/usr/lib/x86_64-linux-gnu' >/etc/ld.so.conf
  - |
    . /tmp/vars
    version="$(ls -1 /lib/modules | head -n1)"
    mkdir -p /tmp/initrd-overlay/usr/lib/systemd/system-generators
    mkdir -p /tmp/initrd-overlay/usr/lib/systemd/system/local-fs-pre.target.wants
    mkdir -p /tmp/initrd-overlay/usr/lib/udev/rules.d
    cp /usr/lib/kde-linux/os-release /tmp/initrd-overlay/usr/lib/os-release
    cp /usr/lib/kde-linux/os-release /tmp/initrd-overlay/usr/lib/initrd-release
    cp /usr/lib/rootfs-transition /tmp/initrd-overlay/usr/lib/rootfs-transition
    cp /usr/lib/systemd/system-generators/kde-linux-live-generator /tmp/initrd-overlay/usr/lib/systemd/system-generators/kde-linux-live-generator
    cp /usr/lib/systemd/system-generators/kde-linux-mount-generator /tmp/initrd-overlay/usr/lib/systemd/system-generators/kde-linux-mount-generator
    cp /usr/lib/udev/rules.d/90-image-dissect.rules /tmp/initrd-overlay/usr/lib/udev/rules.d/90-image-dissect.rules
    cp /usr/lib/systemd/system/etc-factory.service /tmp/initrd-overlay/usr/lib/systemd/system/etc-factory.service
    cp -P /usr/lib/systemd/system/local-fs-pre.target.wants/etc-factory.service /tmp/initrd-overlay/usr/lib/systemd/system/local-fs-pre.target.wants/etc-factory.service
    dracut -v --xz --reproducible --fstab \
      --no-machineid \
      --kernel-image "/lib/modules/${version}/vmlinuz" \
      --kver "${version}" \
      --kernel-cmdline "rw console=tty0 console=ttyS0 quiet" \
      --filesystems "ext4 btrfs erofs" \
      --install 'basename grep fsck.ext4 /usr/lib/btrfs-migrator /usr/lib/etc-factory' \
      --include /tmp/initrd-overlay /
