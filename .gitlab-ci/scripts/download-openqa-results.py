#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>
import io
import json
import os
import urllib.parse
import urllib.request
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any


def get(url: str, token: str, json_response: bool = True) -> Any:
    request = urllib.request.Request(url, headers={"JOB-TOKEN": token})
    with urllib.request.urlopen(request) as response:
        return json.load(response) if json_response else response.read()


def label(xml: bytes, job: str) -> bytes:
    root = ET.fromstring(xml)
    for testcase in root.iter("testcase"):
        testcase.set("classname", f"{job}.{testcase.get('classname')}")
    return ET.tostring(root, encoding="utf-8", xml_declaration=True)


def main() -> None:
    # Fetches JUnit results from the downstream openQA pipeline.
    env = os.environ
    api = env["CI_API_V4_URL"]
    token = env["CI_JOB_TOKEN"]
    project = urllib.parse.quote("kde-linux/os-autoinst-distri-kdelinux", safe="")

    bridges = get(
        f"{api}/projects/{env['CI_PROJECT_ID']}/pipelines/"
        f"{env['CI_PIPELINE_ID']}/bridges",
        token,
    )
    bridge = next(
        (
            bridge
            for bridge in bridges
            if bridge["name"] == "trigger-openqa"
        ),
        None,
    )
    if bridge is None:
        return

    downstream = next(
        (
            bridge["downstream_pipeline"]["id"]
            for bridge in [bridge]
            if bridge["downstream_pipeline"] is not None
        ),
        None,
    )
    if downstream is None:
        return
    jobs = get(f"{api}/projects/{project}/pipelines/{downstream}/jobs", token)
    output = Path("openqa-results")

    for job in jobs:
        if not job.get("artifacts_file"):
            continue
        archive: bytes = get(
            f"{api}/projects/{project}/jobs/{job['id']}/artifacts",
            token,
            False,
        )
        with zipfile.ZipFile(io.BytesIO(archive)) as zipped:
            for name in zipped.namelist():
                if name.startswith("gitlab-artifacts/") and name.endswith("-results.xml"):
                    xml = zipped.read(name)

                    if not xml.strip():
                        print(f"skipping empty XML file {name!r} from job {job['name']!r}")
                        continue

                    try:
                        labelled_xml = label(xml, str(job["name"]))
                    except ET.ParseError as error:
                        print(f"skipping {name!r}: {error}")
                        continue

                    result = output / str(job["id"]) / name
                    result.parent.mkdir(parents=True, exist_ok=True)
                    result.write_bytes(labelled_xml)


if __name__ == "__main__":
    main()
