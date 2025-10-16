#!/usr/bin/python
# SPDX-License-Identifier: GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Nate Graham <nate@kde.org>
# SPDX-FileCopyrightText: 2025 Hadi Chokr <hadichokr@icloud.com>

import sys
import yaml
from pathlib import Path

CONFIG_PATH = Path("/usr/share/not-found/commands.yaml")

def load_yaml(path):
    try:
        with open(path, "r") as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Configuration file not found: {path}")
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML config: {e}")
        sys.exit(1)

data = load_yaml(CONFIG_PATH)

known_alternatives = data.get("known_alternatives", {})
unsupported_package_managers = data.get("unsupported_package_managers", [])
available_package_managers = data.get("available_package_managers", {})

if len(sys.argv) < 2:
    print("Usage: _kde-linux-command-not-found-handler.py <command>")
    sys.exit(1)

command = sys.argv[1]

if command in known_alternatives:
    print(f"\nKDE Linux does not include the “{command}” tool.\n\nInstead, try using “{known_alternatives[command]}”.\n")
    sys.exit(127)

if command in unsupported_package_managers:
    print(f"\nKDE Linux does not include the “{command}” package manager.\n\nGraphical software is available using the Discover app center. To learn how to install software that's not available in Discover, see\nhttps://community.kde.org/KDE_Linux/Install_software_not_available_in_Discover.\n")
    sys.exit(127)

if command in available_package_managers:
    print(f"\nKDE Linux does not pre-install the “{command}” package manager, but it can be added manually.\n\nTo do so, follow the instructions at {available_package_managers[command]}\n")
    sys.exit(127)

print(f"\nKDE Linux does not include the “{command}” command.\n\nIf you know it exists, and it's important for your workflow, learn about options for getting it at\nhttps://community.kde.org/KDE_Linux/Install_software_not_available_in_Discover#Software_not_listed_above\n")
sys.exit(127)

