# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import os
import subprocess
import tempfile
import unittest
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.common.base import AppiumOptions
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from lib.sut import openqa_junit_xml
from lib.sut.atspi import find_pid_on_atspi_bus

# Checks the Package Compatibility Helper opens for an unsupported package type.


class PackageCompatibilityHelperTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        # Create a fake .deb in ~/Downloads. The leading bytes are the ar archive magic
        # followed by "debian-binary" so shared-mime-info detects it as a Debian package
        # and xdg-open routes it to package compatibility helper.
        downloads = os.path.join(os.path.expanduser('~'), 'Downloads')
        os.makedirs(downloads, exist_ok=True)
        fd, self.deb_path = tempfile.mkstemp(suffix='.deb', dir=downloads)
        with os.fdopen(fd, 'wb') as f:
            f.write(b'!<arch>\ndebian-binary')

        # Launch the helper by opening the package, then attach to it by PID.
        self.opener = subprocess.Popen(['xdg-open', self.deb_path])
        pid = find_pid_on_atspi_bus('package-compatibility-helper')

        options = AppiumOptions()
        options.set_capability("app", str(pid))
        self.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)
        self.driver.implicitly_wait(0)

    @classmethod
    def tearDownClass(self):
        self.driver.quit()
        if os.path.exists(self.deb_path):
            os.remove(self.deb_path)

    def test_helper_opens_and_cancels(self):
        """Open a fake .deb so Package Compatibility Helper appears, then exit."""
        cancel_button = WebDriverWait(self.driver, 10).until(
            ec.element_to_be_clickable((AppiumBy.NAME, "Cancel"))
        )
        cancel_button.click()


if __name__ == "__main__":
    openqa_junit_xml.run(PackageCompatibilityHelperTests, "package_compatibility_helper")
