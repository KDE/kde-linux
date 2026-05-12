#!/usr/bin/python
# SPDX-License-Identifier: GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>

import sys
import gettext

gettext.install("kde-linux")

moreSoftwareUrl = "https://kde.org/linux/docs/more-software"
moreSoftwareHomebrewUrl = moreSoftwareUrl + "/#homebrew"
moreSoftwareNixUrl = moreSoftwareUrl + "/#nix"
moreSoftwareOtherUrl = moreSoftwareUrl + "/#software-not-listed-above"

known_alternatives = {
    "adduser" : "useradd",
    "arp" : "ip neigh",
    "cron" : "systemctl list-timers",
    "dig" : "resolvectl query",
    "du" : "btrfs filesystem du",
    "egrep" : "rg",
    "fgrep" : "rg -F",
    "hostname" : "hostnamectl",
    "host" : "resolvectl query",
    "ifconfig" : "ip address",
    "ifdown" : "ip link set [interface] down",
    "ifup" : "ip link set [interface] up",
    "iptunnel" : "ip tunnel",
    "iwconfig" : "iw",
    "nameif" : "ip link",
    "ncdu" : "btrfs filesystem du",
    "netstat" : "ss",
    "nslookup" : "resolvectl query",
    "route" : "ip route",
    "service" : "systemctl",
    "traceroute" : "tracepath"
}

unsupported_package_managers = [
    "apt",
    "dnf",
    "dpkg",
    "npm",
    "pacman",
    "pamac",
    "portage",
    "rpm",
    "yay",
    "yum",
    "zypper"
]

available_package_managers = {
    "brew" : moreSoftwareHomebrewUrl,
    "nix" : moreSoftwareNixUrl
}

related_commands = {
    "nix-env" : "nix",
    "nix-shell" : "nix",
    "nix-store" : "nix",
    "apt-cache" : "apt",
    "apt-config" : "apt",
    "apt-get" : "apt",
    "apt-mark" : "apt"
}

command = sys.argv[1]

if command in related_commands:
    command = related_commands[command]

if command in known_alternatives:
    message = gettext.gettext("KDE Linux does not include the “{}” tool.\n\nInstead, try using “{}”.".format(command, known_alternatives[command]))
elif command in unsupported_package_managers:
    message = gettext.gettext("KDE Linux does not include the “{}” package manager.\n\nGraphical software is available using the Discover app center. To learn how to install software that’s not available in Discover, see {}".format(command, moreSoftwareUrl))
elif command in available_package_managers:
    message = gettext.gettext("KDE Linux does not pre-install the “{}” package manager, but it can be added manually.\n\nTo do so, follow the instructions at {}".format(command, available_package_managers[command]))
else:
    message = gettext.gettext("KDE Linux does not include the “{}” command.\n\nIf you know it exists, and it’s important for your workflow, learn about options for getting it at {}".format(command, moreSoftwareOtherUrl))

print("\n" + message + "\n")
exit(127)
