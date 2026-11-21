# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import os
import unittest
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.common.base import AppiumOptions
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from lib.sut import openqa_junit_xml

# Does a smoke test for file management in Dolphin by creating a file, moving it to trash, then emptying trash.

DOCUMENTS_DIR = os.path.join(os.path.expanduser('~'), 'Documents')
TEST_FILE_NAME = 'kde-linux-openqa-testfile.txt'
TEST_FILE_PATH = os.path.join(DOCUMENTS_DIR, TEST_FILE_NAME)

TRASHED_FILE_PATH = os.path.join(
    os.environ.get('XDG_DATA_HOME', os.path.join(os.path.expanduser('~'), '.local', 'share')),
    'Trash', 'files', TEST_FILE_NAME)


class DolphinTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        os.makedirs(DOCUMENTS_DIR, exist_ok=True)
        with open(TEST_FILE_PATH, 'w') as f:
            f.write('kde-linux-openqa\n')

        options = AppiumOptions()
        options.set_capability("app", "org.kde.dolphin.desktop")
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()
        for path in (TEST_FILE_PATH, TRASHED_FILE_PATH):
            if os.path.exists(path):
                os.remove(path)

    def _wait_path(self, path, exists, timeout=15):
        WebDriverWait(self.driver, timeout).until(
            lambda _: os.path.exists(path) == exists,
            message=f'{path} exists={os.path.exists(path)}, expected exists={exists}')

    def test_delete_file_and_empty_trash(self):
        """Move a file to the trash in Dolphin then empty it."""
        # Navigate to the Documents folder. Ctrl+L focuses the location bar, insert path here.
        ActionChains(self.driver).key_down(Keys.CONTROL).send_keys('l').key_up(Keys.CONTROL).perform()
        entry = self.driver.find_element(
            AppiumBy.ACCESSIBILITY_ID, 'DolphinUrlNavigator.KUrlComboBox.KLineEdit')
        entry.clear()
        entry.send_keys(DOCUMENTS_DIR)
        ActionChains(self.driver).send_keys(Keys.RETURN).perform()

        # Confirm the file is present, then select it via type-ahead. This puts Dolphin in
        # selection mode and the selection-mode bar exposes a clickable trash button.
        self.driver.find_element(AppiumBy.NAME, TEST_FILE_NAME)
        ActionChains(self.driver).send_keys(TEST_FILE_NAME).perform()
        self.driver.find_element(AppiumBy.NAME, 'Move to Trash').click()

        # Verify it's gone and moved on disk
        WebDriverWait(self.driver, 15).until_not(
            ec.presence_of_element_located((AppiumBy.NAME, TEST_FILE_NAME)),
            message=f'{TEST_FILE_NAME!r} was still in the view')
        self._wait_path(TEST_FILE_PATH, exists=False)
        self._wait_path(TRASHED_FILE_PATH, exists=True)

        # Navigate to the trash through the Places panel
        self.driver.find_element(AppiumBy.NAME, 'Trash').click()
        self.driver.find_element(AppiumBy.NAME, 'Empty Trash').click()

        # Confirm the prompt and ensure the correct "Empty Trash" is clicked
        WebDriverWait(self.driver, 10).until(
            ec.element_to_be_clickable((AppiumBy.XPATH, '//dialog//*[@name="Empty Trash"]'))
        ).click()

        # The file now should be gone from the trash view and from disk
        WebDriverWait(self.driver, 15).until_not(
            ec.presence_of_element_located((AppiumBy.NAME, TEST_FILE_NAME)),
            message=f'{TEST_FILE_NAME!r} was still in the trash')
        self._wait_path(TRASHED_FILE_PATH, exists=False)


if __name__ == "__main__":
    openqa_junit_xml.run(DolphinTests, "dolphin")
