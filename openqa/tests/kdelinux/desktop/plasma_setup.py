# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import unittest

from appium import webdriver
from appium.options.common.base import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.support.ui import WebDriverWait

from lib.common import user_manager
from lib.sut import openqa_junit_xml
from lib.sut.atspi import find_pid_on_atspi_bus

# Walks through the Plasma Setup wizard to set up the SUT.
# Fatal test - it's necessary for the system to work in later testing.


class PlasmaSetupTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        options = AppiumOptions()
        options.set_capability("app", str(find_pid_on_atspi_bus('plasma-setup')))
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)
        self.wait = WebDriverWait(self.driver, 10)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()

    def _next_page(self, current_page_title, next_page_title):
        # Ensure we reliably start from the page we expect.
        self.wait.until(
            ec.presence_of_element_located(
                (AppiumBy.NAME, current_page_title)
            )
        )

        def reached_next_page(driver):
            # A prior click was accepted once the heading changes.
            try:
                if driver.find_elements(AppiumBy.CLASS_NAME, f"[label | {next_page_title}]"):
                    return True
            except WebDriverException as error:
                # Catch this transient backend error and ignore it.
                if "'NoneType' object is not iterable" in error.msg:
                    return False
                raise

            driver.find_element(AppiumBy.NAME, "Next").click()
            return False

        self.wait.until(reached_next_page)

    def test_setup(self):
        """Go through and set up the system through Plasma Setup."""
        # Welcome page
        setup_button = self.driver.find_element(AppiumBy.NAME, 'Begin Setup')
        setup_button.click()

        # Language page
        self._next_page("Language", "Keyboard Layout")

        # Keyboard layout page
        self._next_page("Keyboard Layout", "Before we get started…")

        # Dark mode page
        self._next_page("Before we get started…", "About You")

        # User account page
        form = self.driver.find_element(AppiumBy.CLASS_NAME, '[form | ]')

        form.find_elements(AppiumBy.CLASS_NAME, '[text | ]')[0].send_keys('Testy McTestface')
        # clear out auto-generated username testymctestface
        form.find_elements(AppiumBy.CLASS_NAME, '[text | ]')[1].clear()
        form.find_elements(AppiumBy.CLASS_NAME, '[text | ]')[1].send_keys(user_manager.installed().name)
        form.find_elements(AppiumBy.CLASS_NAME, '[password text | ]')[0].send_keys(user_manager.installed().pw)
        form.find_elements(AppiumBy.CLASS_NAME, '[password text | ]')[1].send_keys(user_manager.installed().pw)

        self._next_page("About You", "Hostname")

        # Hostname page
        self._next_page("Hostname", "Time and Date")

        # Timezone page
        # Timezone is pre-set because the TZ page is very flaky and hard to code around. Just skip it.
        self._next_page("Time and Date", "Finish")

        # Finish page
        # "Confirm" to start post-steps.
        confirm_button = self.wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Confirm"))
        )
        confirm_button.click()
        # "Finish" appears when the post-steps ends.
        finish_button = self.wait.until(
            ec.element_to_be_clickable((AppiumBy.CLASS_NAME, "[button | Finish]"))
        )
        finish_button.click()


if __name__ == "__main__":
    openqa_junit_xml.run(PlasmaSetupTests, "plasma_setup")
