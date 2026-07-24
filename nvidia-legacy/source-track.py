#!/bin/env python3
# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: 2026 Harald Sitter <sitter@kde.org>

import requests
import json
import subprocess
import os

ANITYA_TOKEN = os.environ.get("ANITYA_TOKEN")
if not ANITYA_TOKEN:
    raise Exception("ANITYA_TOKEN environment variable not set")

headers = {
    "Authorization": f"Token {ANITYA_TOKEN}"
}

series_to_id = {
    "nvidia-5xx": 387790,
    "nvidia-4xx": 391290,
}

for series, id in series_to_id.items():
    request = {
        "id": str(id)
    }

    r = requests.post('https://release-monitoring.org/api/v2/versions/', headers=headers, data=request)
    if r.status_code != 200:
        raise Exception(f"Request failed with status code {r.status_code}: {r.text}")
    versions = r.json()
    versions["latest_version"]

    # Hot garbage, but it's a convenient way to update without messing up formatting in any way
    subprocess.check_call(["sed", "-i", f"s/  version: .*/  version: {versions['latest_version']}/", f"elements/{series}.bst"])
