# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import unittest
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.common.base import AppiumOptions
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from lib.common import user_manager
from lib.sut import openqa_junit_xml
from lib.sut.atspi import find_pid_on_atspi_bus
import subprocess
import sys

# Installs the system through Calamares.

CALAMARES = '/opt/local/bin/calamares'
LAUNCH_TIMEOUT = 120


class CalamaresTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        # Calamares elevates itself through run0, so the process we spawn here is
        # not the one that ends up on the a11y bus. The driver matches the app
        # against the PID it launched, so launch it ourselves and hand over the
        # PID that actually registers.
        # start_new_session keeps the elevated process out of our process group.
        # The runner TERMs that group on exit and only rescues ESRCH, not the
        # EPERM it gets when the group holds nothing it may signal.
        self.launcher = subprocess.Popen(
            [CALAMARES], stdin=subprocess.DEVNULL, start_new_session=True)
        try:
            pid = find_pid_on_atspi_bus('calamares', timeout=LAUNCH_TIMEOUT)
        except RuntimeError:
            if self.launcher.poll() is not None:
                raise RuntimeError(
                    f'{CALAMARES} exited with {self.launcher.returncode} before '
                    'reaching the a11y bus') from None
            raise

        options = AppiumOptions()
        options.set_capability("app", str(pid))
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()
        # Copy logs so that test can archive that
        subprocess.run(['run0', 'cp', '/root/.cache/calamares/session.log', '/tmp/calamares-session.log'], check=True)

    def _set_text(self, text, element=None):
        # QML text fields seem to not implement AT-SPI EditableText in QT versions older than 6.11
        # and synthesised keystrokes get garbled, so we fall back to using the clipboard here.
        # https://qt-project.atlassian.net/browse/QTBUG-142132
        # With no element (e.g. an external dialog not in our a11y tree) paste blind into
        # whatever currently has focus.
        subprocess.run(['wl-copy', text], check=True)
        if element is not None:
            element.click()
            WebDriverWait(self.driver, 10).until(
                lambda _: element.is_selected(), message='field never gained focus')
        ActionChains(self.driver).key_down(Keys.CONTROL).pause(0.5).send_keys('v').pause(0.5).key_up(Keys.CONTROL).perform()

    def test_install(self):
        """Go through Calamares and install through the standard Erase Disk method."""
        ## Welcome page
        wait = WebDriverWait(self.driver, 20)
        next_button = wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Next"))
        )
        next_button.click()
        ## Partitions page
        self.driver.find_element(by=AppiumBy.XPATH, value="//*[contains(@name, 'Erase disk')]").click()

        if "--encrypted" in sys.argv[1:]:
            ## Enable encrypted install
            self.driver.find_element(by=AppiumBy.XPATH, value="//*[contains(@name, 'Encrypt system')]").click()

            ## Set FDE passphrase
            password = user_manager.installed().pw

            field = WebDriverWait(self.driver, 10).until(ec.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@description, 'Passphrase')]")))
            self._set_text(password, field)

            field = WebDriverWait(self.driver, 10).until(ec.presence_of_element_located((AppiumBy.XPATH, "//*[contains(@description, 'Confirm passphrase')]")))
            self._set_text(password, field)

        # Start install
        next_button.click()

        ## Finished page
        wait = WebDriverWait(self.driver, 300)
        wait.until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Done"))
        )

if __name__ == "__main__":
     openqa_junit_xml.run(CalamaresTests, "calamares_install")
