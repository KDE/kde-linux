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
import time
import subprocess
import signal

# Crashes an application and checks that DrKonqi produces a useful crash report.


class DrkonqiTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        pass

    @classmethod
    def tearDownClass(self):
        pass

    def test_drkonqi(self):
        """Crash Dolphin and verify DrKonqi generates a useful backtrace."""
        # Launch dolphin
        p = subprocess.Popen("dolphin")
        time.sleep(5)

        # Crash it
        p.send_signal(signal.SIGSEGV)
        time.sleep(10)

        # We find "Dolphin Closed Unexpectedly" and click it.
        options = AppiumOptions()
        # get the pid because it will already be launched
        options.set_capability("app", str(find_pid_on_atspi_bus('plasmashell')))
        plasma_driver = webdriver.Remote(command_executor='http://127.0.0.1:4723', options=options)

        wait = WebDriverWait(plasma_driver, 10)

        drkonqi_button = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Dolphin Closed Unexpectedly"))
        )
        drkonqi_button.click()
        time.sleep(10)

        # Now we connect to drkoqni
        options.set_capability("app", str(find_pid_on_atspi_bus('drkonqi')))
        drkonqi_driver = webdriver.Remote(command_executor='http://127.0.0.1:4723', options=options)
        wait = WebDriverWait(drkonqi_driver, 5)

        # Go to backtrace mode
        devinfo_button = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "See Developer Information"))
        )
        devinfo_button.click()

        # Download debug symbols
        debugsym_button = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Install Debug Symbols"))
        )
        debugsym_button.click()

        # make sure crash report is useful
        wait = WebDriverWait(drkonqi_driver, 120)
        # Go to backtrace mode
        wait.until(
            ec.presence_of_all_elements_located((AppiumBy.NAME, "The generated crash information is useful."))
        )

        # cleanup
        drkonqi_driver.quit()


if __name__ == "__main__":
    openqa_junit_xml.run(DrkonqiTests, "drkonqi")
