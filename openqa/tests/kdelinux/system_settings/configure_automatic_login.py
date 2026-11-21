#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 Bhushan Shah <bhushan.shah@machinesoul.in>
# SPDX-License-Identifier: MIT

import subprocess
import time
import unittest
from typing import Final
from appium import webdriver
from appium.options.common.base import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from lib.sut import openqa_junit_xml
from lib.sut.polkit import PolkitAgent

# Enables automatic login for the installed user through System Settings.

KDE_VERSION: Final = 6


class AutoLoginTest(unittest.TestCase):
    """
    Tests for launching systemsettings
    """
    # This is main driver
    driver: webdriver.Remote
    polkit: PolkitAgent

    @classmethod
    def setUpClass(self) -> None:
        options = AppiumOptions()
        options.set_capability("app", "systemsettings")
        options.set_capability("timeouts", {'implicit': 10000})
        options.set_capability("environ", {
            "LC_ALL": "en_US.UTF-8",
            "QT_LOGGING_RULES": "qt.accessibility.atspi.warning=false;qt.qpa.wayland.warning=false;kf.auth.warning=false;kf.plasma.core.warning=false;kf.windowsystem.warning=false;kf.kirigami.platform.warning=false;org.kde.plasma.kcm_feedback.warning=false;qt.qpa.services.warning=false",
        })
        self.driver = webdriver.Remote(command_executor='http://127.0.0.1:4723', options=options)
        self.driver.implicitly_wait(0)

        self.polkit = PolkitAgent()

    @classmethod
    def tearDownClass(self) -> None:
        """
        Make sure to terminate the driver again, lest it dangles.
        """
        subprocess.check_call([f"kquitapp{KDE_VERSION}", "systemsettings"])
        self.polkit.quit()
        self.driver.quit()

    def test_1_enable_autologin(self) -> None:
        """
        Enables autologin for installed user
        """
        wait = WebDriverWait(self.driver, 5)
        self.driver.find_element(by=AppiumBy.NAME, value="Search").send_keys("Login Screen")
        ActionChains(self.driver).send_keys(Keys.DOWN).perform()
        self.driver.find_element(by=AppiumBy.XPATH, value="//list_item[@name='Login Screen' and contains(@states, 'focused')]")
        ActionChains(self.driver).send_keys(Keys.RETURN).perform()

        # checkbox: WebElement = wait.until(ec.presence_of_element_located((AppiumBy.NAME, "as user:")))
        # checkbox.click()

        # Select checkbox "as user:"
        ActionChains(self.driver).send_keys(Keys.TAB).perform()
        time.sleep(1)
        ActionChains(self.driver).send_keys(Keys.TAB).perform()
        time.sleep(1)
        ActionChains(self.driver).send_keys(Keys.TAB).perform()
        time.sleep(1)
        ActionChains(self.driver).send_keys(Keys.SPACE).perform()
        time.sleep(1)

        # Select combobox
        ActionChains(self.driver).send_keys(Keys.TAB).perform()
        time.sleep(1)

        # Select first entry
        ActionChains(self.driver).send_keys(Keys.DOWN).send_keys(Keys.RETURN).perform()
        time.sleep(1)

        # Apply changes
        finish_button = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Apply"))
        )
        finish_button.click()

        # Authenticate the polkit prompt raised by Apply.
        self.polkit.authenticate()

        time.sleep(5)


if __name__ == '__main__':
    openqa_junit_xml.run(AutoLoginTest, "configure_automatic_login")
