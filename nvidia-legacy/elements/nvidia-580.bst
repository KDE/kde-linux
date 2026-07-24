# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: manual

variables:
  version: 580.173.02

build-depends:
- sdk.bst

sources:
- kind: remote
  # If this url disappears use source-track.py to refresh the version reference.
  url: nvidia:Linux-x86_64/%{version}/NVIDIA-Linux-x86_64-%{version}.run
  ref: 8d8eb9001e05a9a8a663d3d5d304feb64ef2844ee185ccdfd952786820f46e1b

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
    sh -x *.run --tmpdir tmp --target installer --extract-only

    cd installer/kernel
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
