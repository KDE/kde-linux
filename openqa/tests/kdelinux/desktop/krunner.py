# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

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

# Checks if KRunner appears and has sane output through basic calculation (i.e. plugins load).


class KRunnerTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        options = AppiumOptions()
        # It might already be up, handle this properly
        try:
            krunner_pid = str(find_pid_on_atspi_bus("krunner", 1))
        except RuntimeError:
            krunner_pid = False

        options.set_capability("app", krunner_pid if krunner_pid else "krunner")
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()

    def test_krunner_appears(self):
        """Check if KRunner appears and has sane output through basic calculation (i.e. plugins load)."""
        if not self.driver.find_elements(AppiumBy.XPATH, '//*[contains(@states, "active")]'):
            # Explicitly activate it because we wouldn't have launched the binary
            ActionChains(self.driver).key_down(Keys.ALT).send_keys(Keys.SPACE).key_up(Keys.ALT).perform()
            self.assertTrue(self.driver.find_elements(AppiumBy.XPATH, '//*[contains(@states, "active")]'))
        else:
            # KRunner should hopefully be active by now since we ran the binary
            self.assertTrue(self.driver.find_elements(AppiumBy.XPATH, '//*[contains(@states, "active")]'))

        # Do a simple math equation to test output sanity
        search = self.driver.find_element(
            AppiumBy.XPATH,
            '//text[@name="Search" and contains(@states, "enabled")'
            ' and contains(@states, "focused") and contains(@states, "editable")]')
        search.send_keys("40+2")

        # Then check the result
        wait = WebDriverWait(self.driver, 5)
        wait.until(ec.presence_of_element_located(
            (AppiumBy.XPATH, '//list_item[@name="42" and @description="in category Calculator"]')))

if __name__ == "__main__":
    openqa_junit_xml.run(KRunnerTests, "krunner")
