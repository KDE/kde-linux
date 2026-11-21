# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import unittest
import subprocess
from lib.sut import openqa_junit_xml
from lib.sut import secret_service

SECRET = "kde-linux-openqa-secret_service_persistence"

# Sets some credentials in the secret service before reboot.
# These are then checked after upgrade in secret_service_persistence_get.py


class SecretServicePersistenceSetTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        secret_service.activate()

    def test_1_secret_service_provider_is_ksecretd(self):
        """Check that the org.freedesktop.secrets provider is ksecretd."""
        exe = secret_service.process_exe()
        self.assertEqual(
            exe,
            "ksecretd",
            f"{secret_service.SECRETS_BUS_NAME} is provided by {exe!r} "
            f"(pid {secret_service.pid()}), expected ksecretd",
        )

    def test_2_set_persistent_credentials(self):
        """Set some credentials in the wallet to check if they persist after reboot."""
        subprocess.run(
            [
                "secret-tool",
                "store",
                f"--label={SECRET}",
                SECRET,
                SECRET,
            ],
            input=f"{SECRET}\n",
            capture_output=True,
            text=True,
            check=True,
        )


if __name__ == "__main__":
    openqa_junit_xml.run(SecretServicePersistenceSetTests, "secret_service_persistence_set")
