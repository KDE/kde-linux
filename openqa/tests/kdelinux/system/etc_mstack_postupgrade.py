# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Philip Grant <pg_kde_invent@runbox.com>

import unittest
from pathlib import Path

from lib.sut import openqa_junit_xml

# Paths of the files which were modified/deleted in the preupgrade test
TEST_MODIFIED_FILE = 'quotatab'
TEST_DELETED_FILE = 'paperspecs'

TEST_CONTENT = '# QA testing for /etc mstack'

ETC = Path('/etc')


class EtcMstackPostUpgradeTests(unittest.TestCase):
    def test_01_etc_mstack_preserves_user_modification(self) -> None:
        # Verify that the test file kept the modification made to it in etc_mstack_preupgrade.py
        with open(ETC / TEST_MODIFIED_FILE) as f:
            etc_content = f.read()
        self.assertEqual(etc_content, TEST_CONTENT)

    def test_02_etc_mstack_preserves_user_deletion(self) -> None:
        # Verify that the file deleted in etc_mstack_preupgrade.py stayed deleted
        self.assertFalse((ETC / TEST_DELETED_FILE).exists())


if __name__ == '__main__':
    openqa_junit_xml.run(EtcMstackPostUpgradeTests, 'etc_mstack_preupgrade')
