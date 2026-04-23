#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

import atexit
import http.server
import sys
import subprocess
import os
import time
import tempfile
from pathlib import Path

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/good':
            sys.exit(0)
        if self.path == '/bad':
            print("==Received /bad callback==")
            content_len = int(self.headers.get('Content-Length'))
            body = self.rfile.read(content_len)
            print(body.decode('utf-8'))
            sys.exit(1)
        self.send_response(200)
        self.end_headers()

server = http.server.HTTPServer(server_address=('', 0), RequestHandlerClass=Handler)
print("serving at port", server.server_port)

img = sys.argv[1]
if not img:
    print("No image specified")
    sys.exit(1)

efi_base = sys.argv[2]
if not efi_base:
    print("No EFI base image specified")
    sys.exit(1)

# Always test as ISO - .raw is also a valid ISO
test_img = img.replace('.raw', '.test.iso').replace('.iso', '.test.iso')
subprocess.check_call(['cp', '--reflink=auto', img, test_img])

# Inject the EFI addon into the ESP partition of the test ISO
script_dir = os.path.dirname(os.path.realpath(__file__))
addon_src = f'{script_dir}/basic-test-efi-addon.sh'

with tempfile.TemporaryDirectory() as mnt:
    # Find the ESP partition offset and size using sfdisk
    sfdisk = subprocess.check_output(['sfdisk', '--json', test_img]).decode()
    import json
    parts = json.loads(sfdisk)['partitiontable']['partitions']
    esp = next(p for p in parts if p.get('type', '') == 'C12A7328-F81F-11D2-BA4B-00A0C93EC93B')
    sector_size = json.loads(sfdisk)['partitiontable']['sectorsize']
    offset = esp['start'] * sector_size
    size = esp['size'] * sector_size

    subprocess.check_call([
        'mount', '-o', f'loop,offset={offset},sizelimit={size}',
        test_img, mnt
    ])
    try:
        efi_extra_dir = f'{mnt}/EFI/Linux/{efi_base}.extra.d'
        os.makedirs(efi_extra_dir, exist_ok=True)
        subprocess.check_call([
            'bash', addon_src
        ], env={
            'PORT': str(server.server_port),
            'UKI': efi_base,
            'ADDON_DIR': efi_extra_dir,
        })
    finally:
        subprocess.check_call(['umount', mnt])

qemu_cmd = [
    "qemu-system-x86_64",
    "-cdrom", test_img,
    "-m", "4G",
    "-enable-kvm",
    "-cpu", "host",
    "-bios", "/usr/share/OVMF/x64/OVMF.4m.fd",
]

# I ought to point out that this leaks the process in case of failure. It will however get reaped by the docker container shutdown.
qemu = subprocess.Popen(qemu_cmd)
atexit.register(lambda: (qemu.kill()))

def on_timeout():
    print("\n\n\n== Test timed out ==")
    print("Download the image for inspection from http://images.kde-linux.haraldsitter.eu/")
    print("(location may have changed to something like https://qoomon.github.io/aws-s3-bucket-browser/index.html?bucket=https://storage.kde.org/ci-artifacts/#).")
    print("Once downloaded run:\n")
    print(f"./basic-test.py {img} {efi_base}\n\n\n")
    qemu.kill()
    sys.exit(2)

server.timeout = 5 * 60 # 5 minutes
server.handle_timeout = on_timeout
while True: # kinda garbage but there seems to be no nice (non-private) poll-or-timeout api
    server.handle_request()
    time.sleep(8)

qemu.kill()
sys.exit(1) # if we get here we timed out = fail
