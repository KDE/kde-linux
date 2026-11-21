# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Bhushan Shah <bhushan.shah@machinesoul.in>

import unittest
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.common.base import AppiumOptions
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from lib.sut import openqa_junit_xml
import subprocess

# Goes through the Plasma Welcome app until completion.
# Will become a bit more useful if we ship our own Welcome page, we can test its functionality.


class PlasmaWelcomeTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        options = AppiumOptions()
        options.set_capability("app", subprocess.run(['pgrep', '-n', '-f', 'plasma-welcome'], capture_output=True, text=True, check=True).stdout.strip()) # get the pid because it will already be launched
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()

    def test_welcome(self):
        """Click through each page of the Plasma Welcome tour to the end."""
        ## Welcome page
        wait = WebDriverWait(self.driver, 20)
        next_button = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Next"))
        )
        next_button.click()

        ## Simple by default
        wait.until(
            ec.presence_of_all_elements_located((AppiumBy.NAME, "Simple by Default"))
        )
        next_button.click()

        ## Powerful when needed
        wait.until(
            ec.presence_of_all_elements_located((AppiumBy.NAME, "Powerful When Needed"))
        )
        next_button.click()

        ## Discover
        wait.until(
            ec.presence_of_all_elements_located((AppiumBy.NAME, "Find Great Apps"))
        )
        next_button.click()

        ## User Feedback
        wait.until(
            ec.presence_of_all_elements_located((AppiumBy.NAME, "Share Anonymous Usage Information"))
        )
        next_button.click()

        ## Finished page
        finish_button = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Finish"))
        )
        finish_button.click()

if __name__ == "__main__":
    openqa_junit_xml.run(PlasmaWelcomeTests, "plasma_welcome")
