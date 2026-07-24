# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

kind: import
description: Import the SDK for building the NVIDIA driver. Mind that you need to manually mount it into the sdk directory.

sources:
 - kind: local
   path: sdk

config:
  target: /
