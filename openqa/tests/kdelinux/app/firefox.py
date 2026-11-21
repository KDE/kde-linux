# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import json
import time
import unittest
from pathlib import Path
from lib.sut import openqa_junit_xml
from lib.sut import flatpak
from lib.common import user_manager

# Check if Firefox's Plasma Integration addon is installed and enabled.

FIREFOX_APP_ID = 'org.mozilla.firefox'
ADDON_ID = 'plasma-browser-integration@kde.org'
INSTALL_TIMEOUT = 120


class FirefoxTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        # Launching Firefox triggers the policy-driven download and install of the add-on.
        self.firefox, _ = flatpak.launch(FIREFOX_APP_ID, 'Firefox')

    @classmethod
    def tearDownClass(self):
        flatpak.quit(FIREFOX_APP_ID)

    def _addon(self):
        """Return the Plasma Integration addon entry, or None if not present yet."""
        home = Path('/home') / user_manager.installed().name
        profiles = home / '.var/app/org.mozilla.firefox/config/mozilla/firefox'
        matches = list(profiles.glob('*/extensions.json'))
        if not matches:
            return None
        addons = json.loads(matches[0].read_text()).get('addons', [])
        return next((a for a in addons if a.get('id') == ADDON_ID), None)

    def test_plasma_integration_installed_and_enabled(self):
        """The Plasma Integration add-on must be installed and enabled in Firefox."""
        deadline = time.monotonic() + INSTALL_TIMEOUT
        addon = self._addon()
        while not (addon and addon.get('active')) and time.monotonic() < deadline:
            time.sleep(2)
            addon = self._addon()

        self.assertIsNotNone(
            addon, f'{ADDON_ID} was not installed within {INSTALL_TIMEOUT}s of launch')
        self.assertTrue(
            addon.get('active'),
            f'{ADDON_ID} did not become active within {INSTALL_TIMEOUT}s '
            f'(userDisabled={addon.get("userDisabled")}, appDisabled={addon.get("appDisabled")})')


if __name__ == '__main__':
    openqa_junit_xml.run(FirefoxTests, 'firefox')
