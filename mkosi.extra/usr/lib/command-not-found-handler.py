#!/usr/bin/python
# SPDX-License-Identifier: GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import sys
import json
from pathlib import Path
from difflib import get_close_matches

# This is created at image build time (mkosi.finalize.d/30-nix.sh.chroot) and is really quick to query,
# as we aren't pinging the network to search packages.
PKG_DB = Path("/usr/share/nix/nixpkgs-db.json")

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
    "service" :"systemctl",
    "traceroute" : "tracepath",
    "vi" : "vim -u NONE -C"
}

unsupported_package_managers = [
    "apt",
    "apt-get",
    "dnf",
    "dpkg",
    "pacman",
    "pamac",
    "portage",
    "rpm",
    "yum",
    "zypper"
]

def get_nix_suggestions(cmd):
    if not PKG_DB.exists():
        return []

    try:
        with PKG_DB.open() as f:
            all_pnames = json.load(f)
    except (json.JSONDecodeError, IOError):
        return []

    cmd_lower = cmd.lower()

    # Try matching exactly first.
    exact_matches = [p for p in all_pnames if p.lower() == cmd_lower]
    if exact_matches:
        return exact_matches[:3]

    # If there aren't any, get close enough fuzzy matches.
    matches = get_close_matches(cmd, all_pnames, n=3, cutoff=0.6)

    return matches

command = sys.argv[1]

if command in known_alternatives:
    print("\nKDE Linux does not include the “%s” tool.\n\nInstead, try using “%s”.\n" % (command, known_alternatives[command]))
    exit(127)

if command in unsupported_package_managers:
    print("\nKDE Linux does not include the “%s” package manager.\n\nGraphical software is available using the Discover app center.\n\nOther software can be installed as a Nix package, using the `nix profile add` command. To learn how to install software that's not available in Discover, see\nhttps://community.kde.org/KDE_Linux/Install_software_not_available_in_Discover.\n" % command)
    exit(127)

suggestions = get_nix_suggestions(command)
if suggestions:
    print(f"\nKDE Linux does not include the “{command}” command.\n\nHowever, “{command}” may be available in these Nix packages:")
    for s in suggestions:
        print(f"  • {s}")
    # Escape codes are for bold text.
    print(f"\nYou can install it for your current user with:\n\n  \033[1mnix profile add 'nixpkgs#{suggestions[0]}'\033[0m\n")
    exit(127)

print ("\nKDE Linux does not include the “%s” command.\n\nIf you know it exists, and it's important for your workflow, learn about options for getting it at\nhttps://community.kde.org/KDE_Linux/Install_software_not_available_in_Discover#Software_not_listed_above\n" % command)
exit(127)
