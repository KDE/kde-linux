# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Bhushan Shah <bhushan.shah@machinesoul.in>

import unittest
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.common.base import AppiumOptions
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from lib.sut import openqa_junit_xml
from lib.sut.atspi import find_pid_on_atspi_bus
from lib.sut.openqa_autoinst import OpenQAAutoinst

# Find the logout button in kickoff and trigger logout action

class LogoutTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        options = AppiumOptions()
        self.openqa_autoinst = OpenQAAutoinst()
        options.set_capability('app', str(find_pid_on_atspi_bus('plasmashell')))
        self.driver = webdriver.Remote(command_executor='http://127.0.0.1:4723', options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        pass

    def setUp(self):
        pass

    def test_1_logout_entry(self):
        """Open the application launcher, search for logout, click on it from results."""
        wait = WebDriverWait(self.driver, 10)
        wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Application Launcher")),
            message='kickoff launcher button not found on the panel').click()
        search = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Search")),
            message='kickoff search field not found')
        search.send_keys('Log Out')

        # Launch the Logout search result.
        wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Log Out")),
            message='Log Out did not appear in the kickoff search results').click()
        try:
            greeter_pid = find_pid_on_atspi_bus('ksmserver-logout-greeter', timeout=30)
        except RuntimeError as error:
            self.fail(f'Logout greeter did not show-up: {error}')

        options = AppiumOptions()
        options.set_capability('app', str(greeter_pid))
        logout_driver = webdriver.Remote(command_executor='http://127.0.0.1:4723', options=options)
        logout_driver.implicitly_wait(0)

        wait = WebDriverWait(logout_driver, 10)
        # Logout now
        wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Log Out Now")),
            message='Log Out Now is not available').click()

        self.openqa_autoinst.call_testapi("assert_screen", "sddm_password_input", 30)


if __name__ == "__main__":
    openqa_junit_xml.run(LogoutTests, "logout")
