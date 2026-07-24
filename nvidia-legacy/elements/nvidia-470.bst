# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: manual

variables:
  version: 470.256.02

build-depends:
- sdk.bst

sources:
- kind: remote
  # If this url disappears use source-track.py to refresh the version reference.
  url: nvidia:Linux-x86_64/%{version}/NVIDIA-Linux-x86_64-%{version}.run
  ref: d6451862deb695bb0447f3b7cd6268f73e81168c10e2c10597ff3fa01349b1de
- kind: local
  path: patches/470/

environment-nocache:
- MAKEFLAGS

environment:
  MAKEFLAGS: -j%{max-jobs}
  # The tarball inside is generated with 1000:1000 ownership and since we are root tar will not automatically change that.
  # So what happens is that it would try to chown(1000,1000) and fall on the nose.
  TAR_OPTIONS: >-
    --no-same-owner
    --no-same-permissions

config:
  build-commands:
  - |
    ls -lah
    sh -x *.run --tmpdir tmp --target installer --extract-only
  - |
    cd installer/kernel

    # Patches courtesy of https://github.com/joanbm/nvidia-470xx-linux-mainline
    apply_patch() {
      patch -Np1 -i "%{build-root}/$1"
    }
    apply_patch 0001-Fix-conftest-to-ignore-implicit-function-declaration.patch
    apply_patch 0002-Fix-conftest-to-use-a-short-wchar_t.patch
    apply_patch 0003-Fix-conftest-to-use-nv_drm_gem_vmap-which-has-the-se.patch
    apply_patch kernel-6.10.patch
    apply_patch kernel-6.12.patch
    apply_patch nvidia-470xx-fix-gcc-15.patch
    apply_patch nvidia-470xx-fix-linux-6.13.patch
    apply_patch nvidia-470xx-fix-linux-6.14.patch
    apply_patch nvidia-470xx-fix-linux-6.15.patch
    apply_patch nvidia-470xx-fix-linux-6.17.patch
    apply_patch nvidia-470xx-fix-linux-6.19-part1.patch
    apply_patch nvidia-470xx-fix-linux-6.19-part2.patch
    apply_patch nvidia-470xx-fix-linux-7.0.patch
    apply_patch nvidia-470xx-fix-linux-7.2-part1.patch
    apply_patch nvidia-470xx-fix-linux-7.2-part2.patch
    apply_patch nvidia-470xx-fix-linux-7.2-part3.patch

    kernel_version=$(basename /usr/lib/modules/*)
    cat <<EOF >>Kbuild
    EXTRA_CFLAGS+=-Wno-error=incompatible-pointer-types
    EOF
    make KERNEL_UNAME="${kernel_version}"

  install-commands:
  # Kernel
  - |
    cd installer/kernel
    kernel_version=$(basename /usr/lib/modules/*)
    make -j1 KERNEL_UNAME="${kernel_version}" modules_install INSTALL_MOD_PATH='%{install-root}%{prefix}'
  # Firmware
  - |
    cd installer/firmware
    for f in *; do
      echo "Installing firmware file: $f"
      install -Dm644 "$f" "%{install-root}%{indep-libdir}/firmware/nvidia/580.173.02/$f"
    done
  # Libraries
  - |
    cd installer/
    for f in *.so.*; do
      install -Dm644 "$f" "%{install-root}%{libdir}/GL/default/lib/$f"
    done
  # Binaries
  - |
    cd installer/
    for f in *; do
      if [[ -x "$f" && ! -d "$f" ]]; then
        install -Dm644 "$f" "%{install-root}%{bindir}/$f"
      fi
    done
  # Systemd
  - |
    cd installer/systemd
    for f in *; do
      if [[ -x "$f" && ! -d "$f" ]]; then
        install -Dm644 "$f" "%{install-root}%{bindir}/$f"
      fi
    done
    # remaning stuff are directories
    install -dm755 "%{install-root}%{indep-libdir}/systemd/"
    # for f in *; do
    cp -r * "%{install-root}%{indep-libdir}/systemd/"
    # done
  # Misc
  - |
    cd installer
    install -Dm644 nvidia_icd.json "%{install-root}%{libdir}/GL/default/lib/vulkan/icd.d/nvidia_icd.json"
    # Mind that in freedesktop-sdk a custom vendors dir is set. Using it is super convenient because this had been the only file in a confext!
    install -Dm644 nvidia.icd "%{install-root}/%{libdir}/GL/OpenCL/vendors/nvidia.icd"
    install -Dm644 10_nvidia.json "%{install-root}%{libdir}/GL/default/share/glvnd/egl_vendor.d/10_nvidia.json"
    install -Dm644 10_nvidia_wayland.json "%{install-root}%{datadir}/egl/egl_external_platform.d/10_nvidia_wayland.json"
    install -Dm644 nvidia_layers.json "%{install-root}%{libdir}/GL/default/share/vulkan/implicit_layer.d/nvidia_layers.json"
