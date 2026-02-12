#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2024-2026 Universal Blue

# https://github.com/ublue-os/brew/blob/eddbb1a432c5a4b3d9ef2d524ef23c13f7855e06/system_files/etc/profile.d/brew.sh
# Prioritize system binaries to prevent brew overriding things like dbus
# See: https://github.com/ublue-os/brew/blob/54b30cc07d3211fca65ca5cc724e9812c8c79b77/system_files/usr/lib/systemd/system/brew-upgrade.service#L17-L22
if [[ -d /home/linuxbrew/.linuxbrew && $- == *i* ]] ; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv | grep -Ev '\bPATH=')"
  HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}"
  export PATH="${PATH}:${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin"
fi
