#! /usr/bin/env bash
# SPDX-FileCopyrightText: None
# SPDX-License-Identifier: CC0-1.0
$XGETTEXT --language=Python mkosi.extra/usr/lib/command-not-found-handler.py -o $podir/kde-linux.pot
$XGETTEXT --language=Shell mkosi.extra/usr/lib/kjar-install --join-existing --output=$podir/kde-linux.pot
