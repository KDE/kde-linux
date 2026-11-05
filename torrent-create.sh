#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2026 Tomaz Canabrava <tcanabrava@kde.org>

# Creates a torrent for the image, using every files.kde.org mirror as a webseed.
# Usage: torrent-create.sh VERSION OUTPUT RAW

set -euo pipefail

VERSION=$1
OUTPUT=$2
RAW=$3

# Fetch into a variable first so set -e catches a curl failure.
html=$(curl --fail --silent --show-error \
    --user-agent "KDELinux/torrent-create.sh" \
    --header "Accept: text/html" \
    https://files.kde.org/last-updated.mirrorlist)

# Mirror base URLs are the <a> hrefs ending in "/", excluding "/" itself and last-updated links.
# <script> blocks are dropped first: the page's map JavaScript contains <a href> strings
# (e.g. the CC-BY-SA attribution) that an HTML parser would not treat as links.
mapfile -t mirrors < <(
    sed -E '/<script/,/<\/script>/d' <<<"$html" |
    grep --only-matching --extended-regexp '<a [^>]*href="[^"]*"' |
    sed -E 's/^.*href="([^"]*)"$/\1/' |
    awk '!/last-updated/ && $0 != "/" && /\/$/'
)

if [ ${#mirrors[@]} -eq 0 ]; then
    echo "No mirrors found in mirror list" >&2
    exit 1
fi

args=(transmission-create
    --tracker udp://tracker.opentrackr.org:1337/announce
    --tracker udp://open.demonii.com:1337/announce
    --tracker udp://open.tracker.cl:1337/announce
    --tracker udp://open.stealth.si:80/announce
    --tracker udp://tracker.torrent.eu.org:451/announce
    --tracker udp://tracker-udp.gbitt.info:80/announce
    --tracker udp://opentracker.io:6969/announce
    --tracker udp://explodie.org:6969/announce)

for url in "${mirrors[@]}"; do
    args+=(--webseed "${url}kde-linux/$(basename "$RAW")")
done

args+=(--comment "KDE Linux $VERSION" --outfile "$OUTPUT.torrent" "$RAW")

"${args[@]}"
