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

# Runs a system update through Discover.


class DiscoverTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        options = AppiumOptions()
        # We speicifically start discover with only sysupdate backend, starting full discover
        # causes quit some instability as well as timing issues because it also depends on e.g.
        # how many flatpak updates are available; and that can cause test instability.
        options.set_capability("app", "plasma-discover --backends systemdsysupdate-backend")
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()

    def test_upgrade(self):
        """Run a full system upgrade."""
        wait = WebDriverWait(self.driver, 60)
        # Send Alt+U to open updates page
        ActionChains(self.driver).key_down(Keys.ALT).send_keys('u').key_up(Keys.ALT).perform()

        # Implicitly click on refresh button
        # This is to make sure we do not start update before all sources are ready
        refresh_button = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Refresh"))
        )
        refresh_button.click()

        # Wait for update button to appear
        update_button = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Update All"))
        )
        update_button.click()

        # Wait for Restart and Install button to be visible but do not click it
        # We will reboot it from test harness.
        wait = WebDriverWait(self.driver, 1000)
        wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Restart and Install Updates"))
        )

if __name__ == "__main__":
    openqa_junit_xml.run(DiscoverTests, "discover_upgrade")
