#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>

# Builds KDE Linux inside of an Arch Linux Docker container.

# Exit immediately if any command fails.
set -e

# Store the absolute path the script is located in to $SCRIPT_DIR.
SCRIPT_DIR="$(readlink --canonicalize "$(dirname "$0")")"

CONTAINER_RUNTIME="docker"
MIRRORS_COUNTRY=""
PARALLEL_DOWNLOADS=""

while [ $# -gt 0 ]; do
  case "$1" in
    --podman)
      CONTAINER_RUNTIME="podman"
      shift
      ;;
    --country)
      MIRRORS_COUNTRY="$2"
      shift 2
      ;;
    --parallel)
      PARALLEL_DOWNLOADS="$2"
      shift 2
      ;;
    --help)  # New help option
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --podman                Use podman instead of docker"
      echo "  --country <country code> Set the country code for mirrors"
      echo "  --parallel <number>     Set the number of parallel downloads"
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

  # podman requires the volume mount points to exist already
  mkdir -p "${SCRIPT_DIR}/kde-linux.cache/pacman"
  mkdir -p "${SCRIPT_DIR}/kde-linux.cache/mkosi.pacman"
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

# Print all commands before they are executed.
# We only do this now not to clutter the printed configuration instructions above.
set -x

# Make sure we have the latest available Arch Linux image.
$CONTAINER_RUNTIME pull archlinux:latest

ENV_OPTIONS=""
if [ -n "$MIRRORS_COUNTRY" ];
then
  ENV_OPTIONS="$ENV_OPTIONS -e MIRRORS_COUNTRY=$MIRRORS_COUNTRY"
fi

if [ -n "$PARALLEL_DOWNLOADS" ];
then
  ENV_OPTIONS="$ENV_OPTIONS -e PARALLEL_DOWNLOADS=$PARALLEL_DOWNLOADS"
fi

# Spin up a new Arch Linux container and run the in_docker.sh script inside of it,
# passing any command line arguments to it and mounting $SCRIPT_DIR to /workspace.
$CONTAINER_RUNTIME run \
  --privileged \
  --volume="${SCRIPT_DIR}:/workspace" \
  --volume="${SCRIPT_DIR}/kde-linux.cache/pacman:/var/cache/pacman/pkg" \
  --volume="${SCRIPT_DIR}/kde-linux.cache/mkosi.pacman:/var/cache/mkosi.pacman" \
  --volume="/dev:/dev" \
  --workdir="/workspace" \
  --rm \
  $ENV_OPTIONS \
  archlinux:latest \
  /workspace/in_docker.sh "$@"
