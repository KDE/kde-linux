# SPDX-License-Identifier: LGPL-2.0-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
# SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

# Checks if the boot has been blessed without any failed units, and returns 1 if not.

import json
import subprocess
import time
import unittest
from pathlib import Path
from lib.sut import openqa_junit_xml

# 1000 is the uid of the live user. always.
BLESS_FILE    = Path('/run/user/1000/kde-linux-bless-session')
POLL_INTERVAL = 5
TIMEOUT       = 120


class BasicTests(unittest.TestCase):

    def test_1_bless_file_appears(self):
        """Wait for the session bless file to appear on successful boot."""
        elapsed = 0
        while elapsed < TIMEOUT:
            if BLESS_FILE.is_file():
                return
            time.sleep(POLL_INTERVAL)
            elapsed += POLL_INTERVAL
        self.fail(f'Timed out after {TIMEOUT}s waiting for bless file')

    def test_2_no_failed_units(self):
        """Check that systemd reports no failed units once the boot is blessed."""
        self.assertTrue(BLESS_FILE.is_file(), 'Bless file not present — run test_1_bless_file_appears first')
        failed = json.loads(subprocess.check_output(['systemctl', '--failed', '--output=json']))
        if not failed:
            return
        messages = []
        for unit in failed:
            msg = f'Failed unit: {unit["unit"]}\n'
            try:
                journal = subprocess.check_output(
                    ['journalctl', '--no-pager', f'_SYSTEMD_UNIT={unit["unit"]}']
                ).decode()
                msg += journal
            except Exception as e:
                msg += f'(could not get journal: {e})'
            messages.append(msg)
        self.fail('\n\n'.join(messages))


if __name__ == '__main__':
    openqa_junit_xml.run(BasicTests, 'basic_test')
