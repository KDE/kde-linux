# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>
# SPDX-FileCopyrightText: 2026 Bhushan Shah <bhushan.shah@machinesoul.in>

from testapi import *
import time
from lib.common import user_manager

def test_flags(self):
    return {'fatal': 1}

def run(self):

    # Turn on the power, in practice if we did reboot,
    # this does nothing
    power('on')

    # FDE_INSTALL=1 indicates full-disk-encryption
    encrypted = get_var('FDE_INSTALL', '0')
    # live mode
    do_install = get_var('DO_INSTALL', '0')
    # First boot after installation
    first_boot = get_var('FIRST_BOOT', '0')
    # This selects the previous boot entry
    boot_prev = get_var('BOOT_PREVIOUS', '0')

    if '1' in (first_boot, do_install, boot_prev):
        # Verify that KDE Linux UEFI screen is visible
        assert_screen('uefi_screen', 'timeout', 30)

        # If we are asked to boot into previous boot by upgrade testcase press "down", wait for 1 second
        if boot_prev == '1':
            send_key('down')
            time.sleep(1)

        # Start the selected image.
        send_key('ret')

    if encrypted == '1' and (first_boot == '1' or do_install == '0'):
        # Enter password for the FDE
        assert_screen('bootup_fde', 'timeout', 30)
        type_string(user_manager.installed().pw, "max_interval", 250)
        send_key('ret')

    # check if we see plymouth, do not make it hard failure as buildstream
    # has a different behavior
    check_screen('booting_screen', 'timeout', 20)
    if not match_has_tag('booting_screen'):
       record_soft_failure('plymouth is not visible')

    if first_boot == '1':
        # Check if we boot into plasma-welcome
        assert_screen('plasma_welcome', 'timeout', 60)
    elif do_install == '1':
        # check if we boot to live desktop
        assert_screen('kickoff_icon_on_panel', 'timeout', 60)
    else:
        # check whether booted into login screen
        assert_screen('sddm_password_input', 'timeout', 60)
