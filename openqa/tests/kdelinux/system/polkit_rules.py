# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

import os
import pwd
import subprocess
import unittest
from lib.common import user_manager
from lib.sut import openqa_junit_xml

# Checks that elevation still needs authentication, for an admin and for an
# account that is not one. Nothing here interacts, so an authorised result means
# something authorises the action outright and the user never sees a prompt.

PKCHECK = '/usr/bin/pkcheck'

# What run0 asks for. auth_admin_keep, so it must never come back authorised
# before anyone has authenticated.
ACTION = 'org.freedesktop.systemd1.manage-units'

# pkcheck exit codes. CHALLENGE is what a prompt looks like from here.
AUTHORISED = 0
REFUSED = 1
CHALLENGE = 2

NON_ADMIN_USER = 'openqapolkit'
NON_ADMIN_UID = 61240


def _run(*args):
    print(f'Running {args}')
    return subprocess.run(args, capture_output=True, text=True, check=False)


def _groups(name):
    return _run('id', '--name', '--groups', name).stdout.split()


class PolkitRulesTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self._forget_account()
        _run('useradd', '--no-create-home', '--uid', str(NON_ADMIN_UID),
             '--shell', '/usr/bin/nologin', NON_ADMIN_USER)

    @classmethod
    def tearDownClass(self):
        self._forget_account()

    @classmethod
    def _forget_account(self):
        _run('userdel', '--force', '--remove', NON_ADMIN_USER)

    def _decision(self, name):
        """polkit's answer for ACTION with nothing to interact with, never a pass."""
        entry = pwd.getpwnam(name)
        # setpriv rather than su or runuser, no PAM and no session of its own.
        process = subprocess.Popen(
            ['setpriv', f'--reuid={entry.pw_uid}', f'--regid={entry.pw_gid}',
             '--clear-groups', 'sh', '-c', 'echo ready; exec sleep 60'],
            stdout=subprocess.PIPE, text=True)
        try:
            # Wait until setpriv has dropped root before querying this PID.
            self.assertEqual(process.stdout.readline(), 'ready\n',
                             f'setpriv failed for {name}')
            result = _run(PKCHECK, '--action-id', ACTION, '--process', str(process.pid))
        finally:
            process.kill()
            process.wait()
            process.stdout.close()

        output = (result.stdout + result.stderr).strip()
        self.assertIn(
            result.returncode, (AUTHORISED, REFUSED, CHALLENGE),
            f'pkcheck could not decide {ACTION} for {name} '
            f'({result.returncode}): {output}')
        self.assertNotEqual(
            result.returncode, AUTHORISED,
            f'{name} is authorised for {ACTION} without authenticating, so nothing '
            f'in this test run ever sees the prompt: {output}')
        return result.returncode

    def test_1_pkcheck_present(self):
        """Without pkcheck the rest of this proves nothing."""
        self.assertTrue(
            os.access(PKCHECK, os.X_OK), f'{PKCHECK} is missing or not executable')

    def test_2_admin_is_prompted(self):
        """The installed user administers the machine, which means a prompt, not a pass."""
        name = user_manager.installed().name
        self.assertIn(
            'wheel', _groups(name), f'{name} is not in wheel, it cannot administer anything')
        self.assertEqual(
            self._decision(name), CHALLENGE,
            f'{name} administers the machine, {ACTION} must ask rather than refuse')

    def test_3_non_admin_gets_no_shortcut(self):
        """An account outside wheel is either challenged or refused, never let through."""
        self.assertNotIn('wheel', _groups(NON_ADMIN_USER))
        self._decision(NON_ADMIN_USER)

    def test_4_wheel_alone_authorises_nothing(self):
        """wheel means may authenticate, not is authorised."""
        result = _run('usermod', '--append', '--groups', 'wheel', NON_ADMIN_USER)
        self.assertEqual(
            result.returncode, 0,
            f'could not put {NON_ADMIN_USER} in wheel: {result.stderr.strip()}')
        self.assertIn('wheel', _groups(NON_ADMIN_USER))
        self.assertEqual(
            self._decision(NON_ADMIN_USER), CHALLENGE,
            f'{NON_ADMIN_USER} is in wheel now, {ACTION} must ask rather than refuse')


if __name__ == '__main__':
    openqa_junit_xml.run(PolkitRulesTests, 'polkit_rules')
