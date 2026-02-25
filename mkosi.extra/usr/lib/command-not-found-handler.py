#!/usr/bin/python
# SPDX-License-Identifier: GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>

import sys

known_alternatives = {
    "adduser" : "useradd",
    "arp" : "ip neigh",
    "cron" : "systemctl list-timers",
    "dig" : "resolvectl query",
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
    "brew" : "https://kde.org/linux/docs/more-software/#homebrew",
    "nix" : "https://kde.org/linux/docs/more-software/#nix"
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
    print("\nKDE Linux does not include the “%s” tool.\n\nInstead, try using “%s”.\n" % (command, known_alternatives[command]))
    exit(127)

if command in unsupported_package_managers:
    print("\nKDE Linux does not include the “%s” package manager.\n\nGraphical software is available using the Discover app center. To learn how to install software that's not available in Discover, see\nhttps://kde.org/linux/docs/more-software.\n" % command)
    exit(127)

if command in available_package_managers:
    print("\nKDE Linux does not pre-install the “%s” package manager, but it can be added manually.\n\nTo do so, follow the instructions at %s\n" % (command, available_package_managers[command]))
    exit(127)

print ("\nKDE Linux does not include the “%s” command.\n\nIf you know it exists, and it's important for your workflow, learn about options for getting it at\nhttps://kde.org/linux/docs/more-software/#software-not-listed-above\n" % command)
exit(127)
