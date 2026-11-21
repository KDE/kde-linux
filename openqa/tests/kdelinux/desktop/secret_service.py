# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import unittest
import subprocess
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.common.base import AppiumOptions
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from lib.sut import openqa_junit_xml
from lib.sut import flatpak
from lib.sut import secret_service

# Verifies the Secret Service provider is ksecretd and works through KeepSecret.

KEEPSECRET_APP_ID = 'org.kde.keepsecret'


class SecretServiceTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.keepsecret, pid = flatpak.launch(KEEPSECRET_APP_ID, 'keepsecret')
        options = AppiumOptions()
        options.set_capability("app", str(pid))
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()
        flatpak.quit(KEEPSECRET_APP_ID)
        # Delete the test entry we created.
        subprocess.run(
            ['secret-tool', 'clear',
             'server', 'kde-linux-openqa wallet test server',
             'user', 'kde-linux-openqa wallet test user'],
            capture_output=True, check=False)

    def _set_text(self, text, element=None, verify=True):
        # QML text fields seem to not implement AT-SPI EditableText in QT versions older than 6.11
        # and synthesised keystrokes get garbled, so we fall back to using the clipboard here.
        # https://qt-project.atlassian.net/browse/QTBUG-142132
        # With no element (e.g. an external dialog not in our a11y tree) paste blind into
        # whatever currently has focus.
        subprocess.run(['wl-copy', text], check=True)
        if element is not None:
            element.click()
            WebDriverWait(self.driver, 10).until(
                lambda _: element.is_selected(), message='field never gained focus')
        ActionChains(self.driver).key_down(Keys.CONTROL).pause(0.5).send_keys('v').pause(0.5).key_up(Keys.CONTROL).perform()
        if element is not None and verify:
            WebDriverWait(self.driver, 10).until(
                lambda _: element.text == text,
                message=f'field never showed {text!r}; last read {element.text!r}')

    def test_1_secret_service_provider_is_ksecretd(self):
        """Check that the org.freedesktop.secrets provider is ksecretd."""
        secret_service.activate()
        exe = secret_service.process_exe()
        self.assertEqual(
            exe, 'ksecretd',
            f'{secret_service.SECRETS_BUS_NAME} is provided by {exe!r} (pid {secret_service.pid()}), expected ksecretd'
        )

    def test_2_keepsecret(self):
        """Check that the secret service is functional through KeepSecret."""
        # Open the new entry dialog.
        wait = WebDriverWait(self.driver, 10)
        wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "New Entry"))
        ).click()

        # Fill in the entry. The fields carry no names or relations, so collect every
        # text widget under the dialog in document order and fill them sequentially.
        entry_values = [
            'kde-linux-openqa wallet test',
            'kde-linux-openqa wallet test password',
            'kde-linux-openqa wallet test user',
            'kde-linux-openqa wallet test server',
        ]
        fields = wait.until(lambda d: d.find_elements(
            AppiumBy.XPATH,
            '//dialog[@name="Create New Entry"]//text'
            ' | //dialog[@name="Create New Entry"]//password_text'))
        self.assertEqual(
            len(fields), len(entry_values),
            f'expected {len(entry_values)} text fields under the dialog, found {len(fields)}')
        password_ids = {e.id for e in self.driver.find_elements(
            AppiumBy.XPATH, '//dialog[@name="Create New Entry"]//password_text')}
        for field, value in zip(fields, entry_values):
            self._set_text(value, field, verify=field.id not in password_ids)

        wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Save"))
        ).click()

        # Search for our entry.
        ActionChains(self.driver).key_down(Keys.CONTROL).pause(0.5).send_keys('f').pause(0.5).key_up(Keys.CONTROL).perform()
        search = self.driver.find_element(
            AppiumBy.XPATH,
            '//text[@name="Search" and contains(@states, "enabled")'
            ' and contains(@states, "focused") and contains(@states, "editable")]')
        self._set_text('kde-linux-openqa wallet test', search)

        # Check if our entry now exists.
        wait.until(ec.presence_of_element_located(
            (AppiumBy.XPATH, '//list_item[@name="kde-linux-openqa wallet test"]')))


if __name__ == "__main__":
    openqa_junit_xml.run(SecretServiceTests, "secret_service")
