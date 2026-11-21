# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import array
import json
import os
import pwd
import re
import select
import subprocess
import unittest

from appium import webdriver
from appium.options.common.base import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.support.ui import WebDriverWait

from lib.common import user_manager
from lib.sut import openqa_junit_xml
from lib.sut.openqa_autoinst import OpenQAAutoinst

# Checks that a base set of accessibility features work in all sessions.


class AccessibilityTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.setup_session = pwd.getpwuid(os.getuid()).pw_name == user_manager.plasma_setup().name
        options = AppiumOptions()
        if self.setup_session:
            # Don't kill plasma setup
            options.set_capability("app", "Root")
        else:
            options.set_capability("app", 'kdialog --title "Accessibility test" --msgbox "Screen reader test"')
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)
        self.wait = WebDriverWait(self.driver, 10)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()

    def setUp(self):
        if self.setup_session:
            self.wait.until(ec.presence_of_element_located((AppiumBy.NAME, 'Begin Setup')))

    def _send_key(self, key):
        self.assertEqual(OpenQAAutoinst().call_testapi('send_key', key), 'pass',
                         f'openQA failed to send {key}')

    def _command(self, *args):
        return subprocess.check_output(args, text=True, timeout=10).strip()

    def _bus(self, *args):
        reply = self._command('busctl', '--user', '--json=short', *args)
        return json.loads(reply)['data'] if reply else None

    def _effects(self):
        return self._bus('get-property', 'org.kde.KWin', '/Effects',
                         'org.kde.kwin.Effects', 'activeEffects')

    def _zoom(self):
        info = self._bus('call', 'org.kde.KWin', '/Effects',
                         'org.kde.kwin.Effects', 'supportInformation', 's', 'zoom')[0]
        match = re.search(r'^targetZoom: ([0-9.]+)$', info, re.MULTILINE)
        self.assertIsNotNone(match, f'KWin did not report its zoom level: {info}')
        return float(match[1])

    def _orca_running(self, _driver=None):
        return subprocess.run(
            ['pgrep', '-u', str(os.getuid()), '-x', 'orca'],
            stdout=subprocess.DEVNULL, check=False, timeout=5,
        ).returncode == 0

    def _set_screen_reader(self, enabled):
        if self._orca_running() != enabled:
            self._send_key('super-alt-s')
        self.wait.until(lambda _: self._orca_running() == enabled,
                        f'Orca did not {"start" if enabled else "stop"}')

    def _record_sound(self, trigger):
        recorder = subprocess.Popen([
            'pw-record', '--raw', '--format=s16', '--rate=16000', '--channels=1',
            '--sample-count=80000', '--properties={"stream.capture.sink": true}', '-',
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            # Wait for samples
            self.assertTrue(select.select([recorder.stdout], [], [], 10)[0],
                            'PipeWire did not start recording')
            beginning = recorder.stdout.read1(3200)
            self.assertTrue(beginning, 'PipeWire closed the recording stream')
            trigger()
            audio, error = recorder.communicate(timeout=10)
            audio = beginning + audio
            # pw-record can exit 1 even when it works!
            self.assertEqual(len(audio), 80000 * 2,
                             f'Recording incomplete, exit code {recorder.returncode}: '
                             f'{error.decode(errors="replace")}')
            samples = array.array('h', audio)
            # Require at least 100 ms above approximately -50 dBFS
            self.assertGreaterEqual(sum(abs(sample) > 100 for sample in samples), 1600,
                                    'There was no captured speech')
        finally:
            if recorder.poll() is None:
                recorder.kill()
            recorder.communicate()

    def _reset_zoom(self):
        self._send_key('super-0')
        self.wait.until(lambda _: self._zoom() == 1, 'Reset shortcut did not reset magnification')
        self.wait.until(lambda _: 'zoom' not in self._effects(), 'Zoom effect remained active')

    def test_screen_reader(self):
        """The session shortcut starts Orca and it produces audio."""
        originally_running = self._orca_running()
        try:
            self._set_screen_reader(False)
            self._set_screen_reader(True)  # pgrep gates creation of the recorder.
            # Ask Orca to announce the default button after capture starts.
            self._record_sound(lambda: self._send_key('insert-e'))
            self._set_screen_reader(False)
        finally:
            self._set_screen_reader(originally_running)

    def test_text_to_speech(self):
        """Speech Dispatcher produces audio by itself."""
        originally_running = self._orca_running()
        try:
            self._set_screen_reader(False)
            self._record_sound(lambda: self._command('spd-say', '--wait', 'This is an accessibility test.'))
        finally:
            self._set_screen_reader(originally_running)

    def test_zoom(self):
        """Shortcuts to zoom in/out in KWin work."""
        try:
            self._reset_zoom()
            self._send_key('super-equal')
            self.wait.until(lambda _: self._zoom() > 1, 'Zoom-in shortcut did not magnify the desktop')
            self.wait.until(lambda _: 'zoom' in self._effects(), 'KWin did not activate zoom')
            enlarged = self._zoom()
            self._send_key('super-equal')
            self.wait.until(lambda _: self._zoom() > enlarged, 'A second zoom-in did not increase magnification')
            enlarged = self._zoom()
            self._send_key('super-minus')
            self.wait.until(lambda _: 1 < self._zoom() < enlarged, 'Zoom-out did not reduce magnification')
        finally:
            self._reset_zoom()

if __name__ == "__main__":
    openqa_junit_xml.run(AccessibilityTests, "a11y")
