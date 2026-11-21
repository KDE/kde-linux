# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

from testapi import *

from lib.common import user_manager
from lib.test import cli_test
from lib.test.cli_session import session


def test_flags(self):
    return {"always_run": 1}


def run(self):
    test = cli_test.CliTest(
        "collect_logs",
        artifacts=["/tmp/kde-linux-collected-logs.tar.zst"],
        timeout=400,
    )
    users = (
        user_manager.installed(),
        user_manager.plasma_setup(),
        user_manager.live(),
    )
    user = next(
        candidate
        for candidate in users
        if session.run(f"id -u {candidate.name} || true").strip()
    )
    test.run_selenium(
        "kdelinux/system/collect_logs.py",
        user=user,
    )
