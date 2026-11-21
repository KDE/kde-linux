# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Philip Grant <pg_kde_invent@runbox.com>

import unittest
from pathlib import Path

from lib.sut import openqa_junit_xml

# Path relative to /etc of existing non-critical files which we will
# modify and delete after the test, ready for the post-upgrade test
TEST_MODIFIED_FILE = 'quotatab'
TEST_DELETED_FILE = 'paperspecs'

TEST_CONTENT = '# QA testing for /etc mstack'

ETC = Path('/etc')
FACTORY_ETC = Path('/usr/share/factory/etc')


class EtcMstackPreupgradeTests(unittest.TestCase):
    def test_00_etc_matches_factory(self) -> None:
        for p in (TEST_MODIFIED_FILE, TEST_DELETED_FILE):
            with open(ETC / p) as f:
                etc_content = f.read()
            with open(FACTORY_ETC / p) as f:
                factory_content = f.read()
            self.assertEqual(etc_content, factory_content)

    @classmethod
    def tearDownClass(cls) -> None:
        # Modify and delete the test files so the postupgrade test
        # can verify that user actions are not overridden by etc-factory
        with open(ETC / TEST_MODIFIED_FILE, 'w') as f:
            f.write(TEST_CONTENT)
        (ETC / TEST_DELETED_FILE).unlink()


if __name__ == '__main__':
    openqa_junit_xml.run(EtcMstackPreupgradeTests, 'etc_mstack_preupgrade')
