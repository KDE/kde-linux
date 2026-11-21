# SPDX-License-Identifier: LGPL-2.0-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

# Checks whether any essential process has ever crashed. Every crash that dumps
# core is recorded by systemd-coredump, so we ask coredumpctl and fail if any of
# the processes we care about show up. This test should be run at the very *end*
# of the test suite.

import json
import os
import signal
import subprocess
import unittest
from lib.sut import openqa_junit_xml

ESSENTIAL_SERVICES = [
    'plasmashell',
    'kwin_wayland',
    'kded6',
    'ksmserver',
    'xdg-desktop-portal',
    'xdg-desktop-portal-kde',
    'kactivitymanagerd',
    'ksecretd',
    'org_kde_powerdevil',
    'polkit-kde-authentication-agent-1',
    'pipewire',
    'pipewire-pulse',
    'wireplumber',
    'baloo_file',
    'dbus-broker',
]


def _signal_name(sig) -> str:
    try:
        return signal.Signals(int(sig)).name
    except (ValueError, TypeError):
        return str(sig)


class DesktopSessionServicesTests(unittest.TestCase):
    def _coredumps(self):
        result = subprocess.run(
            ['coredumpctl', '--json=short', 'list'],
            capture_output=True, text=True, check=False)

        if result.returncode != 0:
            if 'No coredumps found' in result.stderr:
                return []
            self.fail(f'coredumpctl failed ({result.returncode}): {result.stderr.strip()}')
        return json.loads(result.stdout)

    def test_essential_services_running(self):
        """Every essential service for a desktop session must currently be running; fail if not."""
        missing = [
            comm for comm in ESSENTIAL_SERVICES
            if subprocess.run(['pidof', comm], capture_output=True, text=True, check=False).returncode != 0
        ]
        self.assertFalse(
            missing,
            f'required desktop session services not running: {", ".join(missing)}')

    def test_no_crashing_services(self):
        """Fail if any essential desktop service has ever crashed."""
        crashes = {}
        for dump in self._coredumps():
            comm = os.path.basename(dump.get('exe') or '')
            if comm in ESSENTIAL_SERVICES:
                crashes.setdefault(comm, []).append(_signal_name(dump.get('sig')))

        if crashes:
            summary = '; '.join(
                f'{comm} crashed {len(sigs)}x ({", ".join(sigs)})'
                for comm, sigs in sorted(crashes.items()))
            self.fail(f'essential processes have crashed: {summary}')


if __name__ == '__main__':
    openqa_junit_xml.run(DesktopSessionServicesTests, 'desktop_session_services')
