# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

from testapi import *
from lib.test.cli_session import session

def run(self):
    # Enable timeout on the UEFI screen so we can select previous boot
    boot_prev = get_var('BOOT_PREVIOUS', '0')
    if boot_prev == '1':
        session.run('bootctl set-timeout-oneshot 7', wait_result=False)

    # Reboot
    try:
        session.run('systemctl reboot', wait_result=False)
    except RuntimeError: pass
    session.reset()
