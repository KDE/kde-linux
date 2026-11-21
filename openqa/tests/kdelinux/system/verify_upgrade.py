# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Bhushan Shah <bhushan.shah@machinesoul.in>

from testapi import *
from lib.test.cli_session import session

def run(self):

    # This is booted image version
    system_build = session.run('source /usr/lib/os-release; echo $IMAGE_VERSION')
    # This is the BUILD number set by openQA
    test_build = get_var('BUILD')

    # If we are booting in previous boot, BUILD and IMAGE_VERSION should not match
    boot_prev = get_var('BOOT_PREVIOUS', '0')
    if boot_prev == '0':
        assert system_build.strip() == test_build.strip(), f"Both IMAGE_VERSION={system_build} and BUILD={test_build} do not match, upgrade possibly failed"
    else:
        assert system_build.strip() != test_build.strip(), f"Both IMAGE_VERSION={system_build} and BUILD={test_build} match, we could not reboot in old build"

    # After we verify that we upgraded to new system, we will boot to previous
    # image to make sure that old image is still bootable
    set_var('BOOT_PREVIOUS', '1')
