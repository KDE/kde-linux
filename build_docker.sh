#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2024 Bruno Pajdek <brupaj@proton.me>

# Builds KDE Linux inside of an Ubuntu Docker container.

# Exit immediately if any command fails.
set -e

# Store the absolute path the script is located in to $SCRIPT_DIR.
SCRIPT_DIR="$(readlink --canonicalize "$(dirname "$0")")"

CONTAINER_RUNTIME="docker"
BUILDER_IMAGE="kde-linux-builder:local"

while [ $# -gt 0 ]; do
  case "$1" in
    --podman)
      CONTAINER_RUNTIME="podman"
      shift
      ;;
    --help)  # New help option
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

# Exit if Docker or Podman are not available.
if ! command -v "$CONTAINER_RUNTIME" > /dev/null 2>&1; then
  echo "$CONTAINER_RUNTIME not available on the system! Make sure it is installed."
  exit 1
fi

if [ "$CONTAINER_RUNTIME" = "podman" ]; then
  if ! podman info | grep -q 'rootless: false'; then
    echo "Podman must be running in rootful mode. Just run this script as root."
    exit 1
  fi
fi

# Print the image build and container commands.
set -x

# Reuse cached provisioning layers until the Dockerfile changes.
$CONTAINER_RUNTIME build --tag "$BUILDER_IMAGE" "$SCRIPT_DIR"

# Sources are mounted at runtime; the image CMD invokes in_docker.sh once.
mkdir -p "${SCRIPT_DIR}/kde-linux.cache/flatpak" "${SCRIPT_DIR}/kde-linux.cache/buildstream"
$CONTAINER_RUNTIME run \
  --privileged \
  --volume="${SCRIPT_DIR}:/workspace" \
  --volume="${SCRIPT_DIR}/kde-linux.cache/buildstream:/root/.cache/buildstream" \
  --volume="${SCRIPT_DIR}/kde-linux.cache/flatpak:/var/lib/flatpak" \
  --volume="/dev:/dev" \
  --workdir="/workspace" \
  --rm \
  "$BUILDER_IMAGE"
