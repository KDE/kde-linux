# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Anicaa (Kangwei Zhu) <anicaazhu@gmail.com>
from testapi import *
from lib.test.sessions.syscore.plasma_desktop import PlasmaDesktopSession
from lib.common import user_manager

def run(self):
    # We need to cancel wallpaper fader if lockscreen was visible long before this point
    send_key('down')
    # check whether booted into desktop screen
    assert_and_click(
        'sddm_password_input',
        'timeout', 60
    )
    type_string(user_manager.installed().pw, "max_interval", 250)
    send_key('ret')

   # DO_INSTALL = 0 indicates the full system boot up for the first time after installing from live.
   # Check if welcome exists
    do_install = get_var('DO_INSTALL')
    if do_install == '0':
        assert_screen('kdelinux_desktop_welcome', 'timeout', 60)
    PlasmaDesktopSession.ensure_active()
