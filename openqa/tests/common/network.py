# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

import json
import socket
import subprocess
import unittest
import urllib.error
import urllib.request
from lib.sut import openqa_junit_xml

# Verifies networking works end to end. Checks the following:
#   1. a non-loopback link is up
#   2. that link has a routable IP address
#   3. a default route exists
#   4. DNS resolution works
#   5. the public internet is reachable over HTTPS

HOSTS = ['www.kde.org', 'www.google.com']


def _ip_json(*args):
    output = subprocess.check_output(['ip', '--json', *args], text=True)
    return json.loads(output)


class NetworkTests(unittest.TestCase):
    def test_1_link_up(self):
        """At least one non-loopback link must be up with carrier."""
        links = _ip_json('link', 'show')
        up = [link['ifname'] for link in links
              if link['ifname'] != 'lo' and link.get('operstate') == 'UP']
        self.assertTrue(
            up,
            'no non-loopback network interface is up: '
            + ', '.join(f'{link["ifname"]}={link.get("operstate")}'
                        for link in links if link['ifname'] != 'lo'))

    def test_2_has_routable_ip(self):
        """An interface must hold a global scope IP address."""
        addrs = _ip_json('addr', 'show')
        routable = [
            f'{addr["ifname"]}: {info["local"]}'
            for addr in addrs if addr['ifname'] != 'lo'
            for info in addr.get('addr_info', [])
            if info.get('scope') == 'global' and info.get('local')
        ]
        self.assertTrue(
            routable,
            'no interface has a global-scope IP address')

    def test_3_default_route(self):
        """The routing table must contain a default route."""
        routes = _ip_json('route', 'show')
        gateways = [route.get('gateway') or route.get('dev')
                    for route in routes if route.get('dst') == 'default']
        self.assertTrue(
            gateways,
            'no default route is configured')

    def test_4_dns_resolution(self):
        """DNS must resolve hosts."""
        socket.setdefaulttimeout(15)
        errors = []
        for host in HOSTS:
            try:
                socket.getaddrinfo(host, 443, proto=socket.IPPROTO_TCP)
            except socket.gaierror as error:
                errors.append(f'{host}: {error}')
        self.assertFalse(
            errors, 'DNS resolution failed:\n' + '\n'.join(errors))

    def test_5_internet_reachable(self):
        """The internet must be reachable over HTTPS."""
        errors = []
        for host in HOSTS:
            request = urllib.request.Request(
                f'https://{host}/',
                method='HEAD',
                headers={'User-Agent': 'kde-linux-openqa-network-test'})
            try:
                # HTTPError still counts, because we actually received it!
                urllib.request.urlopen(request, timeout=15)
            except urllib.error.HTTPError:
                continue
            except (urllib.error.URLError, OSError) as error:
                errors.append(f'{host}: {error}')
        self.assertFalse(
            errors, 'could not reach the internet over HTTPS:\n' + '\n'.join(errors))


if __name__ == '__main__':
    openqa_junit_xml.run(NetworkTests, 'network')
