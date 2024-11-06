#!/usr/bin/env python3

# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>

# Shrink btrfs. It's a bit awkward because we don't really have a reliable way
# to calculate how much space we actually need. So we first chop off a dynamic
# portion but leave a bit of a buffer behind. Then we keep resizing until the
# resize starts failing.

# TODO we can produce an even more squeezed image by deriving a complete partition
# from the initial partition. https://btrfs.readthedocs.io/en/latest/Seeding-device.html
# It essentially transfers the data from the seed device with nary a fragmentation.
# Requires juggling loop devices though, and the gains are in the sub 500MiB range.

import json
import os
import math
import subprocess
from subprocess import check_output

out = check_output(["btrfs", "--format", "json", "filesystem", "df", "."])
data = json.loads(out)
df = data["filesystem-df"]

size = 0
for block_group in df:
    size += block_group["total"]

# Give 10% buffer space. We'll shrink from there in smaller steps.
size = max(512 * 1024 * 1024, math.ceil(size * 1.1))

subprocess.run(["btrfs", "filesystem", "resize", str(size), "."], check=True)

# With compression one extent is always 128KiB as per btrfs documentation.
extent_size = 128 * 1024
while True:
    try:
        subprocess.run(["btrfs", "filesystem", "resize", f"-{extent_size}", "."], stdout=subprocess.DEVNULL, stdin=subprocess.DEVNULL, check=True)
        subprocess.run(["btrfs", "filesystem", "sync", "."], check=True)
        size -= extent_size
    except subprocess.CalledProcessError as e:
        print(e)
        break

script_dir = os.path.dirname(os.path.realpath(__file__))
with open(f"{script_dir}/btrfs.json", "w") as file:
    # Writing data to a file
    file.write(json.dumps({"size": size}))
