# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Bhushan Shah <bhushan.shah@machinesoul.in>

import unittest
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.common.base import AppiumOptions
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from lib.sut import openqa_junit_xml
import subprocess
import time

# Installs, launches, and uninstalls an application through Discover.


class DiscoverTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        options = AppiumOptions()
        options.set_capability("app", "plasma-discover")
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()


    def test_01_app_install(self):
        """
        This test case installs the kolourpaint application, launches it and uninstalls it.
        """
        wait = WebDriverWait(self.driver, 120)

        wait.until(
            ec.presence_of_all_elements_located((AppiumBy.NAME, "Most Popular"))
        )

        # We find Kolourpaint
        self.driver.find_element(by=AppiumBy.NAME, value="Search").send_keys("KolourPaint")
        ActionChains(self.driver).send_keys(Keys.RETURN).perform()

        # Open apppage
        wait = WebDriverWait(self.driver, 60)
        app_item = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "KolourPaint"))
        )
        app_item.click()

        # Wait for install button to appear
        install_button = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Install from Flathub"))
        )
        install_button.click()

        # Launch app and wait (slightly longer delay to account for network)
        wait = WebDriverWait(self.driver, 300)
        launch_button = wait.until(
            ec.element_to_be_clickable((AppiumBy.XPATH, "//*[@name='Launch' and contains(@states, 'enabled')]"))
        )
        launch_button.click()

        # Add some delay for kolourpaint to actually start
        time.sleep(15)

        # Kill kolourpaint, this will fail if process is not running
        subprocess.check_call(['kill', subprocess.run(['pgrep','-f', '-n', 'kolourpaint'], capture_output=True, text=True, check=True).stdout.strip()])

    def test_02_app_uninstall(self):
        """
        Uninstall KolourPaint through Discover and then clean up its leftover data.
        """
        # For now disable, because Remove button trigger seems random
        self.skipTest("This is broken, skipping for now")

        # Uninstall button
        # wait = WebDriverWait(self.driver, 60)
        # remove_button = wait.until(
        #     ec.element_to_be_clickable((AppiumBy.NAME, "Remove"))
        # )
        # remove_button.click()

        # # Wait until it says app is uninstalled and it has data
        # data_label = wait.until(
        #     ec.presence_of_all_elements_located((AppiumBy.NAME, "KolourPaint is not installed but it still has user data and settings present."))
        # )

        # # We cleanup all data for app
        # trash_button = wait.until(
        #     ec.element_to_be_clickable((AppiumBy.NAME, "Move to Trash"))
        # )
        # trash_button.click()


if __name__ == "__main__":
    openqa_junit_xml.run(DiscoverTests, "discover_install")
