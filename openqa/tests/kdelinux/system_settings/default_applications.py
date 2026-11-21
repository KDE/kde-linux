# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import unittest
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.common.base import AppiumOptions
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from lib.sut import openqa_junit_xml
import subprocess

# Verifies the set default applications, through mimetype and system settings.


class DefaultApplicationsTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        options = AppiumOptions()
        options.set_capability("app", "systemsettings")
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()

    def _default(self, mimetype: str) -> str:
        return subprocess.check_output(['xdg-mime', 'query', 'default', mimetype], text=True).strip()

    def _check_all(self, checks: list[tuple[str, str, str]]):
        failures = [
            f'  {label} expected {want!r}, got {got!r}'
            for label, got, want in checks
            if got != want
        ]
        if failures:
            self.fail('Default application mismatches:\n' + '\n'.join(failures))

    def test_1_xdg_mime_defaults(self):
        """Checks if xdg-mime shows the correct default application handlers."""
        checks = [
            ('web browser (https)', self._default('x-scheme-handler/https'), 'org.mozilla.firefox.desktop'),
            ('web browser (http)',  self._default('x-scheme-handler/http'),  'org.mozilla.firefox.desktop'),
            ('email client',  self._default('x-scheme-handler/mailto'), 'org.mozilla.firefox.desktop'),
            ('phone numbers', self._default('x-scheme-handler/tel'),    'org.kde.kdeconnect.handler.desktop'),
            ('image viewer',  self._default('image/jpeg'),              'org.kde.gwenview.desktop'),
            ('music player',  self._default('audio/mpeg'),              'org.kde.haruna.desktop'),
            ('video player',  self._default('video/mp4'),               'org.kde.haruna.desktop'),
            ('text editor',   self._default('text/plain'),              'org.kde.kwrite.desktop'),
            ('pdf viewer',    self._default('application/pdf'),         'org.kde.okular.desktop'),
            ('file manager',  self._default('inode/directory'),         'org.kde.dolphin.desktop'),
            ('archive mgr',   self._default('application/zip'),         'org.kde.ark.desktop'),
            # TODO Don't check this for now, it's inconsistent.
            # ('map',           self._default('x-scheme-handler/geo'),    'org.kde.kdeconnect.handler.desktop'),
        ]
        self._check_all(checks)

    def test_2_xdg_mime_package_compatibility_helper(self):
        """Unsupported package/executable types should route to Package Compatibility Helper."""
        helper = 'org.kde.package-compatibility-helper.desktop'
        mimetypes = [
            'application/x-ms-dos-executable',
            'application/x-msi',
            'application/x-ms-shortcut',
            'application/vnd.microsoft.portable-executable',
            'application/x-msdownload',
            'application/x-rpm',
            'application/vnd.debian.binary-package',
        ]
        self._check_all([
            (mimetype, self._default(mimetype), helper)
            for mimetype in mimetypes
        ])

    def test_3_system_settings_defaults(self):
        """Checks if the listed defaults in System Settings match the xdg-mime test."""
        # Go to the Default Applications page
        search = self.driver.find_element(
            AppiumBy.XPATH,
            '//text[@name="Search" and contains(@states, "enabled")'
            ' and contains(@states, "focused") and contains(@states, "editable")]')
        search.send_keys("Default applications")
        ActionChains(self.driver).send_keys(Keys.DOWN).perform()
        ActionChains(self.driver).send_keys(Keys.DOWN).perform()
        self.driver.find_element(AppiumBy.XPATH,
            "//list_item[@name='Default Applications' and contains(@states, 'focused')]")
        ActionChains(self.driver).send_keys(Keys.RETURN).perform()

        # Wait for the Default Applications page to load
        WebDriverWait(self.driver, 10).until(
            lambda d: d.find_elements(AppiumBy.XPATH, '//label[@name="Web browser:"]')
        )

        # The comboboxes appear in the same document order as the labels, so match them positionally.
        # If the order changes in system settings, this will need to be updated.
        expected = [
            ('Web browser:',       'Firefox'),
            ('Email client:',      'Firefox'),
            # We don't actually install a calendar app
            ('Calendar:',          None),
            ('Phone Numbers:',     'KDE Connect'),
            ('Image viewer:',      'Gwenview (Nightly)'),
            ('Music player:',      'Haruna (Nightly)'),
            ('Video player:',      'Haruna (Nightly)'),
            ('Text editor:',       'KWrite'),
            ('PDF viewer:',        'Okular (Nightly)'),
            ('File manager:',      'Dolphin'),
            ('Terminal emulator:', 'Konsole'),
            ('Archive manager:',   'Ark (Nightly)'),
            # TODO Don't check this for now, it's inconsistent.
            ('Map:',               None),
        ]

        comboboxes = self.driver.find_elements(AppiumBy.XPATH, '//combo_box')
        # HACK: QTBUG-149451 causes duplicate items to be added to the AT-SPI tree,
        # so use a set to deduplicate them.
        self.assertEqual(
            len(set(comboboxes)), len(expected),
            f'expected {len(expected)} comboboxes, found {len(set(comboboxes))}'
        )

        got_values = [cb.get_attribute('name') for cb in comboboxes]
        self._check_all([
            (label, got, want)
            for (label, want), got in zip(expected, got_values)
            if want is not None
        ])


if __name__ == "__main__":
    openqa_junit_xml.run(DefaultApplicationsTests, "default_applications")
