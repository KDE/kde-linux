# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
# SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

import os
import pwd
import re
import shutil
import subprocess
import time
import unittest
from pathlib import Path
from lib.common import user_manager
from lib.sut import openqa_junit_xml

# Checks the per-user home subvolume snapshots: the config created on login,
# snapshotting a home as its owner, the timeline picking it up, and the config,
# snapshots and home going away with the user.

CONFIGS = Path('/etc/snapper/configs')
SYSCONFIG = Path('/etc/sysconfig/snapper')
UPDATEDB = Path('/etc/updatedb.conf')

CONFIG_HELPER = '/usr/lib/snapper-home-config'
GC_HELPER = '/usr/lib/snapper-home-gc'

UNITS = (
    'snapper-timeline.timer',
    'snapper-cleanup.timer',
    'kde-linux-snapper-home-gc.path',
)

# Throwaway accounts, high enough to not collide with the installed user but
# still inside the range the helpers act on. No account exists for GONE_UID.
SUBVOLUME_USER = 'openqasnapper'
SUBVOLUME_UID = 61234
PLAIN_USER = 'openqaplain'
PLAIN_UID = 61235
GONE_UID = 61236
SYSTEM_UID = 999

GC_TIMEOUT = 90

SNAPPER_CONFIGS_RE = re.compile(r'^SNAPPER_CONFIGS="([^"]*)"', re.MULTILINE)


def _run(*args):
    return subprocess.run(args, capture_output=True, text=True, check=False)


def _journal(unit):
    return _run('journalctl', '--no-pager', '-o', 'cat', '-n', '50', '-u', unit).stdout.strip()


def _is_subvolume(path):
    # Subvolume roots are inode 256.
    try:
        return os.stat(path).st_ino == 256
    except OSError:
        return False


def _settings(path):
    settings = {}
    for line in Path(path).read_text(errors='replace').splitlines():
        line = line.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        key, _, value = line.partition('=')
        settings[key.strip()] = value.strip().strip('"')
    return settings


def _active_configs():
    match = SNAPPER_CONFIGS_RE.search(SYSCONFIG.read_text(errors='replace'))
    return match.group(1).split() if match else []


def _set_active_configs(names):
    text = SYSCONFIG.read_text(errors='replace')
    line = f'SNAPPER_CONFIGS="{" ".join(names)}"'
    match = SNAPPER_CONFIGS_RE.search(text)
    if match is None:
        SYSCONFIG.write_text(f'{text}\n{line}\n')
        return
    SYSCONFIG.write_text(text[:match.start()] + line + text[match.end():])


def _snapshot_numbers(subvolume):
    return sorted(
        path.name
        for path in (Path(subvolume) / '.snapshots').glob('*')
        if path.name.isdigit())


def _listing(path):
    try:
        return sorted(entry.name for entry in Path(path).iterdir()) or 'nothing'
    except OSError as error:
        return str(error)


def _wait(predicate, timeout=30):
    # snapperd finishes deletions after the call returns, and btrfs frees a
    # subvolume in the background, so nothing here is true the instant we ask.
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline and not predicate():
        time.sleep(1)
    return predicate()


class SnapperTests(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.user = pwd.getpwnam(user_manager.installed().name)
        self.user_config = f'home_{self.user.pw_uid}'
        self.snapshots = Path(self.user.pw_dir) / '.snapshots'

    @classmethod
    def tearDownClass(self):
        for name, uid in ((SUBVOLUME_USER, SUBVOLUME_UID), (PLAIN_USER, PLAIN_UID)):
            self._forget_account(name, uid)
        self._forget_config(f'home_{GONE_UID}')
        self._forget_config(f'home_{SYSTEM_UID}')

    @classmethod
    def _forget_config(self, config):
        path = CONFIGS / config
        if path.is_file():
            # --no-dbus because snapperd is not necessarily up.
            _run('snapper', '--no-dbus', '--config', config, 'delete-config')
            path.unlink(missing_ok=True)
        active = _active_configs()
        if config in active:
            _set_active_configs([name for name in active if name != config])

    @classmethod
    def _forget_account(self, name, uid):
        self._forget_config(f'home_{uid}')
        _run('userdel', '--force', name)
        home = Path('/home') / name
        if _is_subvolume(home):
            if _run('btrfs', 'subvolume', 'delete', '--recursive', str(home)).returncode != 0:
                _run('btrfs', 'subvolume', 'delete', str(home))
        elif home.is_dir():
            shutil.rmtree(home, ignore_errors=True)

    def _must_run(self, *args):
        result = _run(*args)
        self.assertEqual(
            result.returncode, 0,
            f'{" ".join(args)} failed ({result.returncode}): {result.stderr.strip()}')
        return result

    def _as_user(self, name, *args):
        # De-escalate via systemd-run directly instead of the run0 sudo shim,
        # same as the host-side harness does for a logged-in user.
        uid = _run('id', '-u', name).stdout.strip()
        return _run(
            'systemd-run', '--pipe', '--quiet', '--collect',
            f'--machine={uid}@.host', f'--uid={name}', '--user', *args)

    def _create_account(self, name, uid, subvolume):
        self._forget_account(name, uid)
        self.addCleanup(self._forget_account, name, uid)

        home = Path('/home') / name
        if subvolume:
            self._must_run('btrfs', 'subvolume', 'create', str(home))
        else:
            home.mkdir(mode=0o700, exist_ok=True)

        self._must_run('useradd', '--no-create-home', '--home-dir', str(home),
                       '--uid', str(uid), '--shell', '/usr/bin/nologin', name)
        entry = pwd.getpwnam(name)
        os.chown(home, entry.pw_uid, entry.pw_gid)
        os.chmod(home, 0o700)
        return home

    def _account_with_config(self):
        home = self._create_account(SUBVOLUME_USER, SUBVOLUME_UID, subvolume=True)
        unit = self._start_config_unit(SUBVOLUME_UID)
        config = CONFIGS / f'home_{SUBVOLUME_UID}'
        self.assertTrue(config.is_file(), f'{config} was not created:\n{_journal(unit)}')
        return home, config

    def _start_config_unit(self, uid):
        unit = f'kde-linux-snapper-home-config@{uid}.service'
        result = _run('systemctl', 'start', unit)
        self.assertEqual(
            result.returncode, 0,
            f'{unit} failed: {result.stderr.strip()}\n{_journal(unit)}')
        return unit

    def test_01_units_enabled_and_running(self):
        """The snapper timers and the passwd watcher must be enabled and running."""
        problems = []
        for unit in UNITS:
            enabled = _run('systemctl', 'is-enabled', unit).stdout.strip()
            if enabled != 'enabled':
                problems.append(f'  {unit} is {enabled or "not installed"}, expected enabled')
                continue
            active = _run('systemctl', 'is-active', unit).stdout.strip()
            if active != 'active':
                problems.append(f'  {unit} is {active}, expected active')
        self.assertFalse(problems, 'unit problems:\n' + '\n'.join(problems))

    def test_02_user_home_is_a_subvolume(self):
        """The installed user's home must be a subvolume, the rest hangs off that."""
        self.assertTrue(
            _is_subvolume(self.user.pw_dir),
            f'{self.user.pw_dir} is not a btrfs subvolume, it cannot be snapshotted')

    def test_03_login_created_the_home_config(self):
        """Logging in must have created the user's home config through user@.service."""
        unit = f'kde-linux-snapper-home-config@{self.user.pw_uid}.service'
        self.assertNotEqual(
            _run('systemctl', 'is-failed', unit).stdout.strip(), 'failed',
            f'{unit} failed:\n{_journal(unit)}')

        path = CONFIGS / self.user_config
        self.assertTrue(path.is_file(), f'{path} was not created on login:\n{_journal(unit)}')

        settings = _settings(path)
        self.assertEqual(
            settings.get('SUBVOLUME'), self.user.pw_dir,
            f'{path} does not point at the user home')
        self.assertEqual(
            settings.get('ALLOW_USERS'), self.user.pw_name,
            f'{path} does not allow {self.user.pw_name}')

    def test_04_snapshots_directory_is_readable_by_the_user(self):
        """SYNC_ACL must let the owner browse their own snapshots without root."""
        self.assertTrue(self.snapshots.is_dir(), f'{self.snapshots} does not exist')
        result = self._as_user(self.user.pw_name, 'ls', '--almost-all', str(self.snapshots))
        self.assertEqual(
            result.returncode, 0,
            f'{self.user.pw_name} cannot read {self.snapshots}: {result.stderr.strip()}')

    def test_05_user_can_snapshot_their_own_home(self):
        """ALLOW_USERS must let the user create, list and delete snapshots."""
        create = self._as_user(
            self.user.pw_name, 'snapper', '--config', self.user_config,
            'create', '--print-number', '--description', 'kde-linux-openqa')
        self.assertEqual(
            create.returncode, 0,
            f'{self.user.pw_name} could not create a snapshot: {create.stderr.strip()}')

        number = create.stdout.strip()
        self.assertTrue(number.isdigit(), f'snapper printed {number!r} instead of a number')
        self.addCleanup(
            _run, 'snapper', '--no-dbus', '--config', self.user_config, 'delete', number)
        self.assertIn(
            number, _snapshot_numbers(self.user.pw_dir),
            f'snapshot {number} did not appear under {self.snapshots}')

        listing = self._as_user(
            self.user.pw_name, 'snapper', '--config', self.user_config, 'list')
        self.assertEqual(
            listing.returncode, 0,
            f'{self.user.pw_name} could not list snapshots: {listing.stderr.strip()}')
        self.assertIn('kde-linux-openqa', listing.stdout, f'snapshot {number} is not listed')

        delete = self._as_user(
            self.user.pw_name, 'snapper', '--config', self.user_config, 'delete', number)
        self.assertEqual(
            delete.returncode, 0,
            f'{self.user.pw_name} could not delete their snapshot: {delete.stderr.strip()}')
        snapshot = self.snapshots / number
        self.assertTrue(
            _wait(lambda: not (snapshot / 'info.xml').exists()),
            f'{self.user.pw_name} deleted snapshot {number} but snapper kept it, '
            f'{snapshot} still holds {_listing(snapshot)}')

    def test_06_baloo_excludes_the_snapshots(self):
        """Baloo must parse the exclusion, not merely have it sitting in a config file."""
        result = self._as_user(
            self.user.pw_name, 'balooctl6', 'config', 'list', 'excludeFolders')
        self.assertEqual(
            result.returncode, 0,
            f'balooctl6 could not list excludeFolders: {result.stderr.strip()}')

        excluded = {
            line.strip().rstrip('/')
            for line in result.stdout.splitlines()
            if line.strip()
        }
        self.assertIn(
            str(self.snapshots), excluded,
            f'baloo does not exclude {self.snapshots}, it excludes {sorted(excluded)}')

    def test_07_updatedb_prunes_the_snapshots(self):
        """locate must not index the snapshots either."""
        if not UPDATEDB.is_file():
            self.skipTest(f'{UPDATEDB} is not present')

        marker = Path(self.user.pw_dir) / 'kde-linux-openqa-locate-marker'
        marker.write_text('kde-linux-openqa\n')
        os.chown(marker, self.user.pw_uid, self.user.pw_gid)
        self.addCleanup(marker.unlink, True)

        create = self._as_user(
            self.user.pw_name, 'snapper', '--config', self.user_config,
            'create', '--print-number', '--description', 'kde-linux-openqa-locate')
        self.assertEqual(
            create.returncode, 0,
            f'could not snapshot the marker: {create.stderr.strip()}')
        number = create.stdout.strip()
        self.addCleanup(
            _run, 'snapper', '--no-dbus', '--config', self.user_config, 'delete', number)

        snapshotted = self.snapshots / number / 'snapshot' / marker.name
        self.assertTrue(
            snapshotted.exists(),
            f'{snapshotted} is missing, the snapshot did not capture the marker')

        database = Path('/tmp/kde-linux-openqa-locate.db')
        self.addCleanup(database.unlink, True)
        self._must_run(
            'updatedb', '--output', str(database),
            '--database-root', self.user.pw_dir)

        found = _run('locate', '--database', str(database), marker.name).stdout.split()
        self.assertIn(
            str(marker), found,
            f'locate did not index {marker} at all, so this test proves nothing')
        self.assertNotIn(
            str(snapshotted), found,
            f'locate indexed {snapshotted}, .snapshots is not pruned')

    def test_08_config_helper_skips_system_uids(self):
        """Neither the helper nor the unit may create a config for a system uid."""
        result = _run(CONFIG_HELPER, str(SYSTEM_UID))
        self.assertEqual(
            result.returncode, 0,
            f'{CONFIG_HELPER} {SYSTEM_UID} failed: {result.stderr.strip()}')

        # The unit guards the range with ExecCondition, which skips instead of failing.
        self._start_config_unit(SYSTEM_UID)
        self.assertFalse(
            (CONFIGS / f'home_{SYSTEM_UID}').exists(),
            f'a config was created for system uid {SYSTEM_UID}')

    def test_09_config_helper_skips_non_subvolume_homes(self):
        """A plain directory home has nothing to snapshot, so it gets no config."""
        self._create_account(PLAIN_USER, PLAIN_UID, subvolume=False)
        self._start_config_unit(PLAIN_UID)
        self.assertFalse(
            (CONFIGS / f'home_{PLAIN_UID}').exists(),
            f'a config was created for {PLAIN_USER}, whose home is not a subvolume')

    def test_10_config_created_for_a_subvolume_home(self):
        """A subvolume home gets a config keyed on the uid and allowed to its owner."""
        home, path = self._account_with_config()
        config = path.name

        settings = _settings(path)
        self.assertEqual(settings.get('SUBVOLUME'), str(home), f'{path} points elsewhere')
        self.assertEqual(
            settings.get('ALLOW_USERS'), SUBVOLUME_USER, f'{path} does not allow its owner')
        self.assertTrue((home / '.snapshots').is_dir(), f'{home}/.snapshots was not created')

        rerun = _run(CONFIG_HELPER, str(SUBVOLUME_UID))
        self.assertEqual(
            rerun.returncode, 0, f'a second run failed: {rerun.stderr.strip()}')
        self.assertEqual(
            _active_configs().count(config), 1,
            f'{config} ended up in {SYSCONFIG} more than once')

    def test_11_timeline_snapshots_the_home_configs(self):
        """The timeline must pick the home configs up out of the sysconfig file."""
        home = Path(self.user.pw_dir)
        before = _snapshot_numbers(home)
        result = _run('systemctl', 'start', 'snapper-timeline.service')
        self.assertEqual(
            result.returncode, 0,
            'snapper-timeline.service failed: '
            f'{result.stderr.strip()}\n{_journal("snapper-timeline.service")}')

        def _new_timeline_snapshot():
            listing = self._as_user(
                self.user.pw_name, 'snapper', '--config', self.user_config,
                'list', '--columns', 'number,type,date').stdout
            for line in listing.splitlines():
                fields = [field.strip() for field in line.split('|')]
                if len(fields) < 3 or fields[0] not in set(_snapshot_numbers(home)) - set(before):
                    continue
                if fields[1] != 'timeline':
                    continue
                try:
                    created = time.mktime(time.strptime(fields[2], '%a %d %b %Y %I:%M:%S %p %Z'))
                except ValueError:
                    continue
                if time.time() - created < 60:
                    return fields[0]
            return None

        number = _wait(lambda: _new_timeline_snapshot() is not None, 60) and _new_timeline_snapshot()

        for leftover in sorted(set(_snapshot_numbers(home)) - set(before)):
            self.addCleanup(
                _run, 'snapper', '--no-dbus', '--config', self.user_config, 'delete', leftover)

        self.assertIsNotNone(
            number,
            f'the timeline did not snapshot {home}:\n{_journal("snapper-timeline.service")}')

    def test_12_gc_deletes_configs_whose_home_is_gone(self):
        """A config pointing at a subvolume that no longer exists must be collected."""
        config = f'home_{GONE_UID}'
        path = CONFIGS / config
        self.addCleanup(self._forget_config, config)

        path.write_text(f'SUBVOLUME="/home/kde-linux-openqa-gone-{GONE_UID}"\nFSTYPE="btrfs"\n')
        _set_active_configs(_active_configs() + [config])

        result = _run(GC_HELPER)
        self.assertEqual(result.returncode, 0, f'{GC_HELPER} failed: {result.stderr.strip()}')
        self.assertFalse(
            path.exists(), f'{config} was kept: {result.stdout.strip()}')
        self.assertNotIn(
            config, _active_configs(), f'{config} was not pruned from {SYSCONFIG}')

    def test_13_deleting_a_user_collects_their_config_and_home(self):
        """Deleting a user must trip the passwd watcher, taking the config and the home with it."""
        home, config = self._account_with_config()

        # The accounts the earlier tests create and delete write /etc/passwd often
        # enough to trip the unit's start rate limit, which would keep the watcher
        # from starting it at all here.
        _run('systemctl', 'reset-failed', 'kde-linux-snapper-home-gc.service')

        self._must_run('userdel', '--force', SUBVOLUME_USER)
        _wait(lambda: not config.exists() and not home.exists(), GC_TIMEOUT)

        journal = _journal('kde-linux-snapper-home-gc.service')
        self.assertFalse(
            config.exists(),
            f'{config} was still there {GC_TIMEOUT}s after deleting {SUBVOLUME_USER}:\n{journal}')
        self.assertNotIn(
            f'home_{SUBVOLUME_UID}', _active_configs(),
            f'home_{SUBVOLUME_UID} is still listed in {SYSCONFIG}:\n{journal}')
        self.assertFalse(home.exists(), f'{home} was not deleted with the account:\n{journal}')


if __name__ == '__main__':
    openqa_junit_xml.run(SnapperTests, 'snapper')
