# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

from testapi import *
from lib.test.cli_session import session

def run(self):
    try:
        session.run('systemctl poweroff', wait_result=False)
    except RuntimeError: pass
    assert_shutdown()
    session.reset()
