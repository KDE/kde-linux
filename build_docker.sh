#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

# Builds KDE Linux inside of a Fedora Docker container.

# Exit immediately if any command fails.
set -e

# Store the absolute path the script is located in to $SCRIPT_DIR.
SCRIPT_DIR="$(readlink --canonicalize "$(dirname "$0")")"

CONTAINER_RUNTIME="docker"

while [ $# -gt 0 ]; do
  case "$1" in
    --podman)
      CONTAINER_RUNTIME="podman"
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --podman                Use podman instead of docker"
      echo "  --help                  Display this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [ "$CONTAINER_RUNTIME" = "podman" ]; then
  if ! podman info | grep -q 'rootless: false'; then
    echo "Podman must be running in rootful mode. Just run this script as root."
    exit 1
  fi

  mkdir -p "${SCRIPT_DIR}/kde-linux.cache/dnf"
  mkdir -p "${SCRIPT_DIR}/kde-linux.cache/mkosi.dnf"
  mkdir -p "${SCRIPT_DIR}/kde-linux.cache/flatpak"
fi

# Exit if Docker or Podman are not available.
if ! command -v "$CONTAINER_RUNTIME" 2>&1 > /dev/null; then
  echo "$CONTAINER_RUNTIME not available on the system! Make sure it is installed."
  exit 1
fi

# Print some configuration instructions if we're not running Docker on btrfs, then exit.
if ! $CONTAINER_RUNTIME info | grep --quiet ": btrfs"; then
  echo "You should run this on a btrfs'd Docker or Podman instance."
  echo "Other storage drivers will not work at all!"
  echo
  echo "If you are running Podman and btrfs:"
  echo "Change the storage driver from overlay to btrfs in /etc/containers/storage.conf"
  echo "and \`rm -rf /var/lib/containers/*\` to wipe out your existing containers."
  echo
  echo "If you use Docker and have btrfs:"
  echo "add the following to /etc/docker/daemon.json:"
  echo
  echo "{"
  echo "  \"storage-driver\": \"btrfs\""
  echo "}"
  echo
  echo "And run:"
  echo
  echo "# systemctl restart docker.socket docker.service"
  echo
  echo "If you are not using btrfs already, create a btrfs filesystem inside of a file"
  echo "and mount it so Docker or Podman can use it. For Podman mount on to /var/lib/containers."
  echo
  echo "# fallocate -l 64G /docker.btrfs"
  echo "# mkfs.btrfs /docker.btrfs"
  echo "# mkdir -p /var/lib/docker"
  echo "# mount /docker.btrfs /var/lib/docker"
  echo
  echo "Then follow the appropriate directions above."
  exit 1
fi

set -x

$CONTAINER_RUNTIME pull fedora:rawhide

$CONTAINER_RUNTIME run \
  --privileged \
  --volume="${SCRIPT_DIR}:/workspace" \
  --volume="${SCRIPT_DIR}/kde-linux.cache/dnf:/var/cache/dnf" \
  --volume="${SCRIPT_DIR}/kde-linux.cache/mkosi.dnf:/var/cache/mkosi.dnf" \
  --volume="${SCRIPT_DIR}/kde-linux.cache/flatpak:/var/lib/flatpak" \
  --volume="/dev:/dev" \
  --workdir="/workspace" \
  --rm \
  fedora:rawhide \
  /workspace/in_docker.sh "$@"
