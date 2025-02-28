# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Hadi Chokr <hadichokr@icloud.com>

import os
import sys

def modify_nsswitch():
    path = "/etc/nsswitch.conf"
    
    print(f"Checking {path}...")  # Debug line
    
    # Read the file
    try:
        with open(path, "r") as file:
            lines = file.readlines()
    except Exception as e:
        print(f"Error reading {path}: {e}", file=sys.stderr)
        raise  # Re-raise the exception

    modified = False

    # Process each line
    for i, line in enumerate(lines):
        print(f"Checking line: {line.strip()}")  # Debug line
        if line.startswith("hosts:"):
            if "mymachines" in line and "mdns_minimal" not in line:
                lines[i] = line.replace("mymachines", "mymachines mdns_minimal [NOTFOUND=return]", 1)
                modified = True
                print("Added mdns_minimal after mymachines.")  # Debug line
            elif "mymachines" not in line and "mdns_minimal" not in line:
                lines[i] = line.replace("hosts:", "hosts: mdns_minimal [NOTFOUND=return] ", 1)
                modified = True
                print("Added mdns_minimal.")  # Debug line
            break

    if not modified:
        raise RuntimeError("Expected modification but no changes were made.")

    # Write back the modified file
    try:
        with open(path, "w") as file:
            file.writelines(lines)
        print("Updated /etc/nsswitch.conf")
    except Exception as e:
        print(f"Error writing to {path}: {e}", file=sys.stderr)
        raise  # Re-raise the exception

if __name__ == "__main__":
    if os.geteuid() != 0:
        print("This script must be run as root.", file=sys.stderr)
        sys.exit(1)
    
    try:
        modify_nsswitch()
    except Exception as e:
        print(f"Fatal error: {e}", file=sys.stderr)
        sys.exit(1)
