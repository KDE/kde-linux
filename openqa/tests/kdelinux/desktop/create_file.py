# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import os
import subprocess
import unittest
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.common.base import AppiumOptions
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from lib.sut import openqa_junit_xml
from lib.sut.atspi import find_pid_on_atspi_bus

# Creates a new text file on the desktop and verifies it appears.

DESKTOP_DIR = os.path.join(os.path.expanduser('~'), 'Desktop')
TEST_FILE_NAME = 'kde-linux-openqa-testfile.txt'
TEST_FILE_PATH = os.path.join(DESKTOP_DIR, TEST_FILE_NAME)


class CreateFileTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        options = AppiumOptions()
        options.set_capability("app", str(find_pid_on_atspi_bus('plasmashell')))
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        if os.path.exists(TEST_FILE_PATH):
            os.remove(TEST_FILE_PATH)

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

    def _wait_path(self, path, exists, timeout=15):
        WebDriverWait(self.driver, timeout).until(
            lambda _: os.path.exists(path) == exists,
            message=f'{path} exists={os.path.exists(path)}, expected exists={exists}')

    def test_1_create_file_on_desktop(self):
        """Create a new text file on the desktop and verify it appears."""

        # Find the desktop
        desktop = self.driver.find_element(by=AppiumBy.XPATH, value="//frame[contains(@name, 'Desktop')]")
        wait = WebDriverWait(self.driver, 5)

        # Bring up the ctx menu
        ActionChains(self.driver).move_to_element_with_offset(desktop, 100, 100).context_click(desktop).perform()

        # Traverse ctx menu
        # Context menus don't come up on AT-SPI bus, so, traverse with keyboard
        ActionChains(self.driver) \
            .send_keys(Keys.ARROW_DOWN) \
            .send_keys(Keys.RETURN) \
            .send_keys(Keys.ARROW_DOWN) \
            .send_keys(Keys.ARROW_DOWN) \
            .send_keys(Keys.RETURN) \
            .perform()

        # Create the new file
        self._set_text(TEST_FILE_NAME)
        ActionChains(self.driver).send_keys(Keys.RETURN).perform()

        # Check if we now have an entry on the desktop
        wait.until(
            ec.presence_of_element_located((AppiumBy.CLASS_NAME, f"[canvas | {TEST_FILE_NAME}]"))
        )

    def test_2_verify_file_existence(self):
        self._wait_path(TEST_FILE_PATH, True)


if __name__ == "__main__":
    openqa_junit_xml.run(CreateFileTests, "create_file")
