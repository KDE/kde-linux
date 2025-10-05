#!/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

import atexit
import http.server
import sys
import subprocess
import os
import time
import threading

from pathlib import Path

test_completed = threading.Event()
test_success = False

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/good':
            print("Test PASSED - received /good callback")
            global test_success
            test_success = True
            test_completed.set()
        if self.path == '/bad':
            print("Test FAILED - received /bad callback")
            test_completed.set()
        self.send_response(200)
        self.end_headers()

server = http.server.HTTPServer(server_address=('', 0), RequestHandlerClass=Handler)
print("Serving at port", server.server_port)

# Start server in background thread so it's listening while we prepare the image
def serve():
    server.serve_forever()

server_thread = threading.Thread(target=serve)
server_thread.daemon = True
server_thread.start()

img = sys.argv[1]
if not img:
    print("No image specified")
    sys.exit(1)
test_img = img.replace('.raw', '.test.raw')

efi_base = sys.argv[2]
if not efi_base:
    print("No EFI base image specified")
    sys.exit(1)

print("Inject test into image")
subprocess.check_call(['cp', '--reflink=auto', img, test_img])
#subprocess.check_call(['systemd-dissect', test_img, '--with', f'{os.path.dirname(os.path.realpath(__file__))}/basic-test-efi-addon.sh'],
#                      env={'PORT': str(server.server_port),
#                           'UKI': efi_base},
#                      stdout=sys.stdout, stderr=sys.stderr)

# I ought to point out that this leaks the process in case of failure. It will however get reaped by the docker container shutdown.
print("Booting image in qemu")
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
    "-append", f"kde-linux.basic-test=1 kde-linux.basic-test-callback=http://10.0.2.2:{server.server_port}/good",
])
atexit.register(lambda: (qemu.kill()))

print("Waiting for call back...")
if test_completed.wait(timeout=5*60):
    server.shutdown()
    qemu.kill()
    sys.exit(0 if test_success else 1)
else:
    print("Test FAILED - Timeout")
    server.shutdown()
    qemu.kill()
    sys.exit(1)
