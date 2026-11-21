# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import os
import subprocess
import unittest
from pathlib import Path
from lib.sut import openqa_junit_xml
from lib.sut.polkit import PolkitAgent

# Tests the dev tools shipped in the image, toggle-developer-mode and set-up-system-development.

# So we always get one single polkit prompt at the start, instead of multiple inconsistently throughout.
TOGGLE_DEVELOPER_MODE     = '/usr/bin/toggle-developer-mode'
SET_UP_SYSTEM_DEVELOPMENT = '/usr/bin/set-up-system-development'
OPT_APPS = Path('/opt/local/share/applications')

# run0 --empower sanitises the environment to a minimal PATH without ~/.local/bin, which the script needs.
LOCAL_BIN_PATH = (
    f'--setenv=PATH={Path.home() / ".local" / "bin"}'
    ':/usr/local/sbin:/usr/local/bin:/usr/bin')


class SystemDevelopmentTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.polkit = PolkitAgent()

    @classmethod
    def tearDownClass(self):
        self.polkit.quit()

    def _dev_mode_enabled(self) -> bool:
        return (OPT_APPS / 'GammaRay.desktop').exists()

    def _toggle(self, expect_prompt=False):
        proc = subprocess.Popen(
            ['run0', '--empower', TOGGLE_DEVELOPER_MODE],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        self.polkit.authenticate(required=expect_prompt)
        try:
            _, stderr = proc.communicate(timeout=30)
        except subprocess.TimeoutExpired:
            proc.kill()
            _, stderr = proc.communicate()
            self.fail(f'{TOGGLE_DEVELOPER_MODE} timed out: {stderr.strip()}')
        self.assertEqual(
            proc.returncode, 0,
            f'{TOGGLE_DEVELOPER_MODE} failed: {stderr.strip()}')

    def test_1_developer_mode_script_present(self):
        """The developer mode toggle must be installed and executable."""
        self.assertTrue(
            os.access(TOGGLE_DEVELOPER_MODE, os.X_OK),
            f'{TOGGLE_DEVELOPER_MODE} is missing or not executable')

    def test_2_toggle_developer_mode(self):
        """Toggling must show/hide the bundled developer app launchers."""
        started_enabled = self._dev_mode_enabled()

        # First toggle flips the state. It is also the first elevation of the
        # session, so it has to prompt.
        self._toggle(expect_prompt=True)
        self.assertEqual(
            self._dev_mode_enabled(), not started_enabled,
            'toggling developer mode did not flip its state')

        if not started_enabled:
            for app in [
                'GammaRay.desktop',
                'org.kde.heaptrack.desktop',
                'org.kde.plasma.lookandfeelexplorer.desktop',
                'org.kde.plasma.themeexplorer.desktop',
                'org.kde.plasmaengineexplorer.desktop',
            ]:
                path = OPT_APPS / app
                self.assertTrue(
                    path.is_file(), f'{path} was not installed by enabling developer mode')
                self.assertNotIn(
                    'NoDisplay=true', path.read_text(),
                    f'{path} is still hidden by NoDisplay=true after enabling')

        # Second toggle leaves the system as we found it.
        self._toggle()
        self.assertEqual(
            self._dev_mode_enabled(), started_enabled,
            'developer mode did not return to its original state')

    def test_3_set_up_system_development(self):
        """Setting up system development must install kde-builder and configure."""
        self.assertTrue(
            os.access(SET_UP_SYSTEM_DEVELOPMENT, os.X_OK),
            f'{SET_UP_SYSTEM_DEVELOPMENT} is missing or not executable')

        # Downloads and installs kde-builder, so it needs network and some time.
        first_run = subprocess.Popen(
            ['run0', '--empower', LOCAL_BIN_PATH, SET_UP_SYSTEM_DEVELOPMENT],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        self.polkit.authenticate(required=False)
        try:
            _, stderr = first_run.communicate(timeout=60)
        except subprocess.TimeoutExpired:
            first_run.kill()
            _, stderr = first_run.communicate()
            self.fail(f'{TOGGLE_DEVELOPER_MODE} timed out: {stderr.strip()}')
        self.assertEqual(
            first_run.returncode, 0,
            f'{SET_UP_SYSTEM_DEVELOPMENT} failed: {stderr.strip()}')

        kde_builder = Path.home() / '.local' / 'bin' / 'kde-builder'
        config = Path.home() / '.config' / 'kde-builder.yaml'
        self.assertTrue(kde_builder.is_file(), f'{kde_builder} was not installed')
        self.assertTrue(config.is_file(), f'{config} was not created')

        # A second run must find everything already in place and do nothing.
        second_run = subprocess.Popen(
            ['run0', '--empower', LOCAL_BIN_PATH, SET_UP_SYSTEM_DEVELOPMENT],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        self.polkit.authenticate(required=False)
        try:
            stdout, stderr = second_run.communicate(timeout=60)
        except subprocess.TimeoutExpired:
            second_run.kill()
            _, stderr = second_run.communicate()
            self.fail(f'{TOGGLE_DEVELOPER_MODE} timed out: {stderr.strip()}')
        self.assertEqual(
            second_run.returncode, 0,
            f'second {SET_UP_SYSTEM_DEVELOPMENT} run failed: {stderr.strip()}')

        self.assertIn(
            'Nothing to do!', stdout,
            'set-up-system-development was not idempotent on a second run')


if __name__ == '__main__':
    openqa_junit_xml.run(SystemDevelopmentTests, 'system_development')
