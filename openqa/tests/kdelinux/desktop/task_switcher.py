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
from lib.sut import openqa_junit_xml

# Checks that Alt+Tab task switcher moves focus between windows.
# The switcher is not on the a11y bus and is a part of KWin, so
# check the active state of KDialog windows.


def _has_active_window(driver):
    """Whether the driver's application is the focused one."""
    return bool(driver.find_elements(AppiumBy.XPATH, '//*[contains(@states, "active")]'))


class TaskSwitcherTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        # Launch window 2 first and wait for it to focus, then do the same for
        # window 1.
        self.proc2, self.driver2 = self._spawn_dialog("kde-linux-openqa 2")
        WebDriverWait(self.driver2, 15).until(
            _has_active_window, message='second window never gained focus')
        self.proc1, self.driver1 = self._spawn_dialog("kde-linux-openqa 1")
        WebDriverWait(self.driver1, 15).until(
            _has_active_window, message='first window never gained focus')

    @classmethod
    def _spawn_dialog(self, title):
        env = dict(os.environ, QT_ACCESSIBILITY='1', QT_LINUX_ACCESSIBILITY_ALWAYS_ON='1')
        proc = subprocess.Popen(['kdialog', '--title', title, '--msgbox', title], env=env)
        options = AppiumOptions()
        options.set_capability('app', str(proc.pid))
        driver = webdriver.Remote(command_executor='http://127.0.0.1:4723', options=options)
        return proc, driver

    @classmethod
    def tearDownClass(self):
        for driver in (self.driver1, self.driver2):
            driver.quit()
        for proc in (self.proc1, self.proc2):
            proc.terminate()

    def test_alt_tab_switches_windows(self):
        """Open two windows, Alt+Tab, and verify focus moves to the other one."""
        self.assertTrue(_has_active_window(self.driver1), 'window 1 should start focused')
        self.assertFalse(_has_active_window(self.driver2), 'window 2 should not start focused')

        ActionChains(self.driver1).key_down(Keys.ALT).send_keys(Keys.TAB).key_up(Keys.ALT).perform()

        WebDriverWait(self.driver2, 10).until(
            _has_active_window, message='Alt+Tab did not move focus to window 2')
        WebDriverWait(self.driver1, 10).until_not(
            _has_active_window, message='window 1 was still focused after Alt+Tab')


if __name__ == "__main__":
    openqa_junit_xml.run(TaskSwitcherTests, "task_switcher")
