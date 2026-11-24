# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Philip Grant <pg_kde_invent@runbox.com>

import asyncio
import platform
import unittest

import yaml

from lib.sut import openqa_junit_xml, systemd_unit_state


class FlatpakPreinstallerTests(unittest.TestCase):
    """ Test that the Flatpak preinstall mechanism is in a good state,
    to the extent not already shown by other tests. (We'll know from
    other tests if Firefox didn't get installed, or if any or the
    relevant services failed.)
    """
    HISTORY_FILE_PATH = "/var/lib/kde-linux/preinstalled-flatpak-history.yaml"

    @classmethod
    def setUpClass(cls) -> None:
        # Wait for the startup-time preinstaller service to be done. (When
        # testing an upgrade that adds a new app, this service will spend time
        # pulling the app from the remote over the internet.)
        asyncio.run(asyncio.wait_for(
            systemd_unit_state.wait_while_unit_state(
                "kde-linux-install-new-flatpaks.service",
                "active_state",
                ["active"]),
            timeout=300))

    def test_01_history_file_is_valid(self) -> None:
        """ Verify that the preinstaller history file exists, is
        valid YAML readable by yaml.safe_load(), and records that a
        successful preinstaller run was executed for the current image
        or a later one.
        """
        version = platform.freedesktop_os_release()["IMAGE_VERSION"]
        with open(self.HISTORY_FILE_PATH) as f:
            history = yaml.safe_load(f)
        self.assertIsInstance(history, dict)
        self.assertIn("apps", history)
        self.assertIn("last_completed_image_version", history)
        self.assertGreaterEqual(history["last_completed_image_version"], version)


if __name__ == '__main__':
    openqa_junit_xml.run(FlatpakPreinstallerTests, 'flatpak_preinstaller')