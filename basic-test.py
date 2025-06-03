#!/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

import http.server
import sys
import subprocess
import os
import time

from pathlib import Path

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/good':
            sys.exit(0)
        if self.path == '/bad':
            sys.exit(1)
        self.send_response(200)
        self.end_headers()

server = http.server.HTTPServer(server_address=('', 0), RequestHandlerClass=Handler)
print("serving at port", server.server_port)

img = sys.argv[1]
if not img:
    print("No image specified")
    sys.exit(1)
test_img = img.replace('.raw', '.test.raw')

efi_base = sys.argv[2]
if not efi_base:
    print("No EFI base image specified")
    sys.exit(1)

subprocess.check_call(['cp', '--reflink=auto', img, test_img])
subprocess.check_call(['systemd-dissect', test_img, '--with', f'{os.path.dirname(os.path.realpath(__file__))}/basic-test-efi-addon.sh'],
                      env={'PORT': str(server.server_port),
                           'UKI': efi_base},
                      stdout=sys.stdout, stderr=sys.stderr)

# I ought to point out that this leaks the process in case of failure. It will however get reaped by the docker container shutdown.
qemu = subprocess.Popen([
    "qemu-system-x86_64",
    "-drive",
    f"file={test_img},format=raw",
    "-m",
    "4G",
    "-enable-kvm",
    "-cpu",
    "host",
    "-bios",
    "/usr/share/OVMF/x64/OVMF.4m.fd",
])
server.timeout = 5 * 60 # 5 minutes
server.handle_timeout = lambda: (qemu.kill(), sys.exit(1))
while True: # kinda garbage but there seems to be no nice (non-private) poll-or-timeout api
    server.handle_request()
    time.sleep(8)
qemu.kill()
sys.exit(1) # if we get here we timed out = fail
