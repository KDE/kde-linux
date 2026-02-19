#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>

import argparse
import json
import sys
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(description="Apply simple Flatpak manifest module fixups.")
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--remove", action="append", default=[], metavar="MODULE")
    parser.add_argument("--add-module", action="append", default=[], nargs=2, metavar=("PARENT", "MODULE"))
    return parser.parse_args()


def walk_modules(container):
    for module in container.get("modules", []):
        yield module
        yield from walk_modules(module)


def remove_modules(container, removed):
    if "modules" not in container:
        return

    modules = []
    for module in container["modules"]:
        if module.get("name") in removed:
            continue
        remove_modules(module, removed)
        modules.append(module)
    container["modules"] = modules


def main():
    args = parse_args()

    with args.manifest.open() as handle:
        manifest = json.load(handle)

    removed = set(args.remove)
    remove_modules(manifest, removed)

    additions = {}
    for parent, module in args.add_module:
        additions.setdefault(parent, []).append({"name": module})

    for module in walk_modules(manifest):
        module_name = module.get("name")
        if module_name in additions:
            module.setdefault("modules", []).extend(additions[module_name])

    json.dump(manifest, sys.stdout, indent=2)
    print()


if __name__ == "__main__":
    main()
