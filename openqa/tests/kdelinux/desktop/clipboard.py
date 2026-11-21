# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

# TODO test outside of Qt apps and flatpaks, they may misbehave when Qt apps work fine

import unittest
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.common.base import AppiumOptions
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from lib.sut import openqa_junit_xml
from lib.sut import flatpak

# Checks that text copies and pastes between an application and the system clipboard.

CLIPBOARD_TO_APP = 'kde-linux-openqa clipboard into app'
APP_TO_CLIPBOARD = 'kde-linux-openqa app into clipboard'
KWRITE_APP_ID = 'org.kde.kwrite'


class ClipboardTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.kwrite, pid = flatpak.launch(KWRITE_APP_ID, 'kwrite')
        options = AppiumOptions()
        options.set_capability("app", str(pid))
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()
        flatpak.kill(KWRITE_APP_ID)

    def setUp(self):
        ActionChains(self.driver).key_down(Keys.CONTROL).send_keys('n').key_up(Keys.CONTROL).perform()
        self._dismiss_save_dialog()

    def _editor(self):
        return self.driver.find_element(
            AppiumBy.XPATH, '//text[contains(@states, "editable") and contains(@states, "focused")]')

    def _editor_text(self):
        return self._editor().text.rstrip('\n')

    def _select_all_and_copy(self):
        ActionChains(self.driver).key_down(Keys.CONTROL).send_keys('a').key_up(Keys.CONTROL).perform()
        ActionChains(self.driver).key_down(Keys.CONTROL).send_keys('c').key_up(Keys.CONTROL).perform()

    def _dismiss_save_dialog(self):
        els = self.driver.find_elements(
            AppiumBy.XPATH, '//*[@name="Discard"]')
        if els:
            els[0].click()

    def test_1_app_copies_to_clipboard(self):
        """Text copied from an application ends up on the clipboard."""
        self._editor().send_keys(APP_TO_CLIPBOARD)
        self._select_all_and_copy()

        self.assertEqual(self.driver.get_clipboard_text().rstrip('\n'), APP_TO_CLIPBOARD)

    def test_2_clipboard_pastes_into_app(self):
        """Text on the clipboard can be pasted into an application."""
        # NB: set_clipboard is broken for some reason
        self._editor().send_keys(CLIPBOARD_TO_APP)
        self._select_all_and_copy()

        ActionChains(self.driver).key_down(Keys.CONTROL).send_keys('a').key_up(Keys.CONTROL).perform()
        ActionChains(self.driver).send_keys(Keys.DELETE).perform()
        ActionChains(self.driver).key_down(Keys.CONTROL).send_keys('v').key_up(Keys.CONTROL).perform()

        self.assertEqual(self._editor_text(), CLIPBOARD_TO_APP)


if __name__ == "__main__":
    openqa_junit_xml.run(ClipboardTests, "clipboard")
