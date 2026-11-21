# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import os
import time
import unittest
from pathlib import Path
from appium import webdriver
from appium.options.common.base import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from lib.sut import openqa_junit_xml
from lib.sut import systemtray
from lib.sut.atspi import find_pid_on_atspi_bus

# Creates a Plasma Vault through its system tray applet, and
# verifies it is opened by checking the vault is mounted.

VAULT_NAME = 'kde-linux-openqa-vault'
VAULT_MOUNTPOINT = Path.home() / 'Vaults' / VAULT_NAME


class VaultsTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        options = AppiumOptions()
        options.set_capability('app', str(find_pid_on_atspi_bus('plasmashell')))
        self.driver = webdriver.Remote(command_executor='http://127.0.0.1:4723', options=options)
        self.driver.implicitly_wait(0)

        # The vault wizard is a kded6 dialog.
        kded_options = AppiumOptions()
        kded_options.set_capability('app', str(find_pid_on_atspi_bus('kded6')))
        self.kded_driver = webdriver.Remote(command_executor='http://127.0.0.1:4723', options=kded_options)

    @classmethod
    def tearDownClass(self):
        self.kded_driver.quit()
        self.driver.quit()

    def test_create_and_open_vault(self):
        """Creating a vault and opening it must make its mountpoint accessible."""
        systemtray.expand(self.driver)
        systemtray.entry(self.driver, 'Vaults').click()

        WebDriverWait(self.driver, 10).until(
            ec.element_to_be_clickable((AppiumBy.NAME, 'Create a New Vault…'))).click()

        wizard = WebDriverWait(self.kded_driver, 10)
        password = 'kde-linux-openqa'

        # Name page.
        wizard.until(
            ec.element_to_be_clickable((AppiumBy.CLASS_NAME, '[text | Vault name:]'))
        ).send_keys(VAULT_NAME)
        wizard.until(
            ec.element_to_be_clickable((AppiumBy.CLASS_NAME, '[push button | Next]'))
        ).click()

        # Password page.
        wizard.until(
            ec.element_to_be_clickable((AppiumBy.CLASS_NAME, '[password text | ]'))
        ).send_keys(password)
        self.kded_driver.find_element(
            AppiumBy.CLASS_NAME, '[password text | Verify:]').send_keys(password)
        wizard.until(
            ec.element_to_be_clickable((AppiumBy.CLASS_NAME, '[push button | Next]'))
        ).click()

        # Mount point page.
        wizard.until(
            ec.element_to_be_clickable((AppiumBy.CLASS_NAME, '[push button | Next]'))
        ).click()
        wizard.until(
            ec.element_to_be_clickable((AppiumBy.CLASS_NAME, '[push button | Create]'))
        ).click()

        # Now check if it works.
        deadline = time.time() + 30
        while time.time() < deadline and not os.path.ismount(VAULT_MOUNTPOINT):
            time.sleep(0.5)
        self.assertTrue(
            os.path.ismount(VAULT_MOUNTPOINT),
            f'{VAULT_MOUNTPOINT} is not mounted after creating the vault')


if __name__ == '__main__':
    openqa_junit_xml.run(VaultsTests, 'vaults')
