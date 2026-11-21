# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>
# SPDX-FileCopyrightText: 2026 Bhushan Shah <bhushan.shah@machinesoul.in>

# ruff: noqa: N999

from testapi import *

from lib.common import user_manager
from lib.test import cli_test


def test_flags(self):
    return {"fatal": 1}


def run(self):
    encrypted = get_var("FDE_INSTALL", "0")
    install_mode = "--encrypted" if encrypted == "1" else "--default"

    test = cli_test.CliTest(
        "calamares_install",
        artifacts=["/tmp/calamares-session.log"],
        timeout=300,
    )
    test.run_selenium(
        "kdelinux-live/calamares_install.py",
        user=user_manager.live(),
        args=install_mode,
    )
    set_var("FIRST_BOOT", "1")
