#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2026 Tomaz Canabrava <tcanabrava@kde.org>

"""Create a torrent for an image, using files.kde.org mirrors as webseeds."""

import argparse
from html.parser import HTMLParser
from pathlib import Path
import subprocess
import sys
from urllib.error import URLError
from urllib.request import Request, urlopen


class MirrorParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.mirrors = []

    def handle_starttag(self, tag, attrs):
        if tag != "a":
            return
        href = dict(attrs).get("href")
        if href and href.endswith("/") and href != "/" and "last-updated" not in href:
            self.mirrors.append(href)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("version")
    parser.add_argument("output")
    parser.add_argument("raw")
    args = parser.parse_args()

    request = Request(
        "https://files.kde.org/last-updated.mirrorlist",
        headers={"User-Agent": "KDELinux/torrent-create.py", "Accept": "text/html"},
    )
    try:
        with urlopen(request) as response:
            html = response.read().decode(response.headers.get_content_charset() or "utf-8")
    except (URLError, OSError, UnicodeError) as error:
        print(f"Could not fetch mirror list: {error}", file=sys.stderr)
        return 1

    mirrors = MirrorParser()
    mirrors.feed(html)
    if not mirrors.mirrors:
        print("No mirrors found in mirror list", file=sys.stderr)
        return 1

    command = ["transmission-create"]
    for tracker in (
        "udp://tracker.opentrackr.org:1337/announce",
        "udp://open.demonii.com:1337/announce",
        "udp://open.tracker.cl:1337/announce",
        "udp://open.stealth.si:80/announce",
        "udp://tracker.torrent.eu.org:451/announce",
        "udp://tracker-udp.gbitt.info:80/announce",
        "udp://opentracker.io:6969/announce",
        "udp://explodie.org:6969/announce",
    ):
        command.extend(["--tracker", tracker])
    for mirror in mirrors.mirrors:
        command.extend(["--webseed", f"{mirror}kde-linux/{Path(args.raw).name}"])
    command.extend([
        "--comment", f"KDE Linux {args.version}",
        "--outfile", f"{args.output}.torrent", args.raw,
    ])
    try:
        return subprocess.run(command, check=False).returncode
    except OSError as error:
        print(f"Could not run transmission-create: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
