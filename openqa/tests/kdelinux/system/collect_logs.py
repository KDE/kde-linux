# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import getpass
import glob
import os
import shutil
import subprocess
import tempfile
import unittest
from lib.common import user_manager
from lib.sut import openqa_junit_xml
from lib.sut.polkit import PolkitAgent

# Tests collect-logs, which creates a .tar.zst archive of system information.

COLLECT_LOGS = '/usr/bin/collect-logs'

# collect-logs runs inxi before it reaches its run0 call, so the prompt is late.
PROMPT_TIMEOUT = 90


class CollectLogsTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.polkit = PolkitAgent()

    @classmethod
    def tearDownClass(self):
        self.polkit.quit()

    def test_1_produces_redacted_tarball(self):
        """collect-logs must exist, and running collect-logs must create a .tar.zst in the CWD."""
        self.assertTrue(
            os.access(COLLECT_LOGS, os.X_OK),
            f'{COLLECT_LOGS} is missing or not executable')

        work_dir = tempfile.mkdtemp()
        proc = subprocess.Popen(
            [COLLECT_LOGS], cwd=work_dir,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        # The live user has no password and is authorised outright, so only the
        # installed user gets a prompt for run0 dmesg.
        if getpass.getuser() == user_manager.installed().name:
            self.polkit.authenticate(timeout=PROMPT_TIMEOUT, required=False)
        try:
            _, stderr = proc.communicate(timeout=300)
        except subprocess.TimeoutExpired:
            proc.kill()
            _, stderr = proc.communicate()
            self.fail(f'{COLLECT_LOGS} timed out: {stderr.strip()}')
        self.assertEqual(
            proc.returncode, 0,
            f'{COLLECT_LOGS} failed: {stderr.strip()}')

        bundles = glob.glob(os.path.join(work_dir, 'kde-linux-logs-*.tar.zst'))
        self.assertEqual(
            len(bundles), 1,
            f'expected exactly one log bundle, found: {bundles}')
        bundle = bundles[0]
        self.assertGreater(os.path.getsize(bundle), 0, 'the log bundle is empty')

        # The bundle must be a valid tarball with diagnostics in it.
        listing = subprocess.run(
            ['tar', '--zstd', '-tf', bundle], capture_output=True, text=True, check=False)
        self.assertEqual(
            listing.returncode, 0,
            f'the bundle is not a readable zstd tarball: {listing.stderr.strip()}')
        for expected in ('summary.txt', 'env.txt'):
            self.assertIn(
                expected, listing.stdout,
                f'{expected} is missing from the log bundle')

        # Redaction must have worked.
        extract_dir = tempfile.mkdtemp()
        subprocess.run(
            ['tar', '--zstd', '-xf', bundle, '-C', extract_dir], check=True)
        env_txt = glob.glob(os.path.join(extract_dir, '*', 'env.txt'))[0]
        with open(env_txt) as f:
            env_contents = f.read()
        self.assertIn(
            '<user-redacted>', env_contents,
            'collect-logs did not redact the username from env.txt')

        # Move file to path where openQA archives it
        shutil.move(bundle, '/tmp/kde-linux-collected-logs.tar.zst')


if __name__ == '__main__':
    openqa_junit_xml.run(CollectLogsTests, 'collect_logs')
