# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

# On btrfs systems, wrap du to use btrfs fi du for accurate disk usage reporting.
# Falls back to system du for unsupported flags or non-btrfs paths.
function du() {
  # Whitelist of flags supported by btrfs fi du
  # Any unrecognised flag falls back to system du
  local arg
  for arg in "$@"; do
    case "$arg" in
      --) break ;;
      -s|--summarize|\
      --raw|\
      --human-readable|\
      --iec|\
      --si|\
      --kbytes|\
      --mbytes|\
      --gbytes|\
      --tbytes) ;;
      -*)
        command du "$@"
        return
        ;;
    esac
  done

  # Parse opts and paths, respecting --
  local opts=()
  local file_paths=()
  local end_of_opts=false

  while [[ $# -gt 0 ]]; do
    if [[ "$end_of_opts" == false && "$1" == "--" ]]; then
      end_of_opts=true
      shift
    elif [[ "$end_of_opts" == false && "$1" == -* ]]; then
      opts+=("$1")
      shift
    else
      file_paths+=("$1")
      shift
    fi
  done

  # Fall back to system du if no paths given
  if [[ ${#file_paths[@]} -eq 0 ]]; then
    command du "${opts[@]}"
    return
  fi

  # Check all paths are on btrfs
  local can_use_btrfs=true
  for path in "${file_paths[@]}"; do
    local fs
    fs="$(findmnt -n -o FSTYPE --target "$path" 2>/dev/null)"
    if [[ "$fs" != "btrfs" ]]; then
      can_use_btrfs=false
      break
    fi
  done

  if [[ "$can_use_btrfs" == true ]]; then
    btrfs fi du "${opts[@]}" "${file_paths[@]}"
  else
    command du "${opts[@]}" "${file_paths[@]}"
  fi
}