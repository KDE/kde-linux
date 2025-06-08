import unittest
from unittest.mock import patch, MagicMock, call
import subprocess
import sys
import os
import shutil

SCRIPT_NAME = "btrfs_snap_manager.py"
SCRIPT_MODULE_NAME_FOR_PATCHING = SCRIPT_NAME.replace('.py', '')
SCRIPT_PATH_FOR_EXECUTION = f"/app/{SCRIPT_NAME}"

TEST_SNAPS_TEMP_DIR = "/tmp/btrfs_manager_test_snaps_actual"

class TestBtrfsSnapManager(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        if os.path.exists(SCRIPT_PATH_FOR_EXECUTION) and not os.access(SCRIPT_PATH_FOR_EXECUTION, os.X_OK):
             os.chmod(SCRIPT_PATH_FOR_EXECUTION, 0o755)

        script_actual_parent_dir = os.path.dirname(SCRIPT_PATH_FOR_EXECUTION)
        if script_actual_parent_dir not in sys.path:
            sys.path.insert(0, script_actual_parent_dir)

    def setUp(self):
        self.test_snapshot_dir = TEST_SNAPS_TEMP_DIR
        if os.path.exists(self.test_snapshot_dir):
            shutil.rmtree(self.test_snapshot_dir)
        os.makedirs(self.test_snapshot_dir, exist_ok=True)

        self.home_backup = os.environ.get("HOME")
        os.environ["HOME"] = "/tmp"

    def tearDown(self):
        if os.path.exists(self.test_snapshot_dir):
            shutil.rmtree(self.test_snapshot_dir)
        if self.home_backup is not None:
            os.environ["HOME"] = self.home_backup
        else:
            if "HOME" in os.environ:
                 del os.environ["HOME"]

    def run_script(self, args, expect_success=True, mock_env_extra=None, stdin_input=None):
        cmd = ["/usr/bin/python3", SCRIPT_PATH_FOR_EXECUTION] + args
        env = os.environ.copy()
        env['BTRFS_SNAP_MANAGER_TEST_SNAPSHOT_DIR'] = self.test_snapshot_dir
        if mock_env_extra: env.update(mock_env_extra)

        process_input = str(stdin_input) if stdin_input is not None else None
        try:
            process = subprocess.run(
                cmd, capture_output=True, text=True, check=False, env=env, input=process_input
            )
            if expect_success and process.returncode != 0:
                print(f"RUN_SCRIPT STDOUT: {process.stdout}") # For debugging failing tests
                print(f"RUN_SCRIPT STDERR: {process.stderr}")
                self.fail(f"Script failed unexpectedly with args {args}. RC: {process.returncode}")
            elif not expect_success and process.returncode == 0:
                print(f"RUN_SCRIPT STDOUT: {process.stdout}") # For debugging failing tests
                print(f"RUN_SCRIPT STDERR: {process.stderr}")
                self.fail(f"Script succeeded unexpectedly with args {args}. RC: {process.returncode}")
            return process
        except FileNotFoundError:
            self.fail(f"Interpreter /usr/bin/python3 or script {SCRIPT_PATH_FOR_EXECUTION} not found. Cmd: {' '.join(cmd)}")
        except Exception as e:
            self.fail(f"run_script encountered an error: {e}. Cmd: {' '.join(cmd)}")

    # 1. Argument Parsing Tests
    def test_argparse_list_valid(self):
        self.run_script(['list'])

    def test_argparse_restore_valid_but_rsync_missing(self):
        os.makedirs(os.path.join(self.test_snapshot_dir, "home-snap1", "some"), exist_ok=True)
        with open(os.path.join(self.test_snapshot_dir, "home-snap1", "some", "file.txt"), 'w') as f: f.write("content")
        process = self.run_script(['restore', 'home-snap1', 'some/file.txt', 'dest/path'], stdin_input='y', expect_success=False)
        self.assertIn("Error: Command 'rsync' not found.", process.stderr)

    def test_argparse_delete_valid_but_not_root(self):
        os.makedirs(os.path.join(self.test_snapshot_dir, "home-snap1"), exist_ok=True)
        process = self.run_script(['delete', 'home-snap1'], stdin_input='y', expect_success=False)
        self.assertIn("Error: Deleting snapshots requires root privileges.", process.stderr)

    def test_argparse_invalid_command(self):
        process = self.run_script(['invalidcommand'], expect_success=False)
        self.assertIn("invalid choice: 'invalidcommand'", process.stderr)

    def test_argparse_restore_missing_args(self):
        process = self.run_script(['restore'], expect_success=False)
        self.assertIn("the following arguments are required: snapshot_name, target_path", process.stderr)

    # 2. Help Message Tests
    def test_help_main_h(self):
        process = self.run_script(['-h'])
        self.assertIn(f"usage: {SCRIPT_NAME}", process.stdout)

    def test_help_main_help(self):
        process = self.run_script(['--help'])
        self.assertIn(f"usage: {SCRIPT_NAME}", process.stdout)

    def test_help_list_subcommand(self):
        process = self.run_script(['list', '--help'])
        self.assertIn(f"usage: {SCRIPT_NAME} list [-h]", process.stdout)

    def test_help_restore_subcommand(self):
        process = self.run_script(['restore', '--help'])
        self.assertIn(f"usage: {SCRIPT_NAME} restore [-h]\n                                     snapshot_name target_path\n                                     [destination_path]", process.stdout)

    def test_help_delete_subcommand(self):
        process = self.run_script(['delete', '--help'])
        self.assertIn(f"usage: {SCRIPT_NAME} delete [-h] snapshot_name", process.stdout)

    # 3. List Command
    def test_list_snapshots_format(self):
        snap1_name = "home-2023-01-01_10-00-00"
        snap2_name = "home-2023-01-02_12-00-00"
        os.makedirs(os.path.join(self.test_snapshot_dir, snap1_name), exist_ok=True)
        os.makedirs(os.path.join(self.test_snapshot_dir, snap2_name), exist_ok=True)
        open(os.path.join(self.test_snapshot_dir, "not-a-snapshot-dir.txt"), 'w').close()
        process = self.run_script(['list'])
        self.assertIn(f"Available snapshots in {self.test_snapshot_dir}:", process.stdout)
        self.assertIn(f"{snap1_name} (Created: 2023-01-01 10:00:00)", process.stdout)
        self.assertIn(f"{snap2_name} (Created: 2023-01-02 12:00:00)", process.stdout)
        self.assertNotIn("not-a-snapshot-dir.txt", process.stdout)

    def test_list_snapshot_dir_not_found_in_script(self):
        shutil.rmtree(self.test_snapshot_dir)
        process = self.run_script(['list'], expect_success=False)
        self.assertIn(f"Error: Snapshot directory {self.test_snapshot_dir} not found.", process.stderr)
        os.makedirs(self.test_snapshot_dir, exist_ok=True)

    # 4. Restore Command
    def test_restore_rsync_not_found(self):
        snap_name = "home-2023-10-26_12-00-00"
        target_item_rel = "Documents/MyFile.txt"
        os.makedirs(os.path.join(self.test_snapshot_dir, snap_name, os.path.dirname(target_item_rel)), exist_ok=True)
        with open(os.path.join(self.test_snapshot_dir, snap_name, target_item_rel), 'w') as f: f.write("snap content")

        original_base_path = os.environ["HOME"]
        original_item_abs_path = os.path.join(original_base_path, target_item_rel)
        os.makedirs(os.path.dirname(original_item_abs_path), exist_ok=True)
        with open(original_item_abs_path, 'w') as f: f.write("original content")

        process = self.run_script(['restore', snap_name, target_item_rel], stdin_input='y', expect_success=False)
        self.assertIn("Error: Command 'rsync' not found.", process.stderr)
        if os.path.exists(original_item_abs_path): shutil.rmtree(os.path.dirname(original_item_abs_path))

    def test_restore_user_cancel(self):
        snap_name = "home-snap1"
        target_item_rel = "file.txt"
        os.makedirs(os.path.join(self.test_snapshot_dir, snap_name, os.path.dirname(target_item_rel)), exist_ok=True)
        with open(os.path.join(self.test_snapshot_dir, snap_name, target_item_rel), 'w') as f: f.write("content")
        original_file_path = os.path.join(os.environ["HOME"], target_item_rel)
        os.makedirs(os.path.dirname(original_file_path), exist_ok=True)
        with open(original_file_path, 'w') as f: f.write("original content to be backed up")

        process = self.run_script(['restore', snap_name, target_item_rel], stdin_input='n')
        self.assertIn("Restore cancelled by user.", process.stdout)
        self.assertEqual(process.returncode, 0)
        if os.path.exists(original_file_path): os.remove(original_file_path) # Clean up

    # 5. Delete Command
    def test_delete_btrfs_not_found(self):
        snap_name = "home-snap-to-delete"
        snapshot_full_path = os.path.join(self.test_snapshot_dir, snap_name)
        os.makedirs(snapshot_full_path, exist_ok=True)

        process = self.run_script(['delete', snap_name], stdin_input='y', expect_success=False)
        if "Error: Deleting snapshots requires root privileges." in process.stderr:
            print("INFO: test_delete_btrfs_not_found: Skipped btrfs check, hit permission error first.")
            self.skipTest("Cannot test btrfs call without root-like environment for geteuid().")
        else:
            self.assertIn("Error: Command 'btrfs' not found.", process.stderr)

    def test_delete_as_non_root(self):
        snap_name = "home-snap1"
        os.makedirs(os.path.join(self.test_snapshot_dir, snap_name), exist_ok=True)
        process = self.run_script(['delete', snap_name], expect_success=False, stdin_input='y')
        self.assertIn("Error: Deleting snapshots requires root privileges.", process.stderr)

    def test_delete_user_cancel(self):
        snap_name = "home-snap1"
        os.makedirs(os.path.join(self.test_snapshot_dir, snap_name), exist_ok=True)

        # Expect script to fail if not root, or succeed if it is root and user cancels.
        process = self.run_script(['delete', snap_name], stdin_input='n', expect_success=False)

        if "Error: Deleting snapshots requires root privileges." in process.stderr:
            print("INFO: test_delete_user_cancel: Hit permission error before cancel prompt.")
            self.assertEqual(process.returncode, 1)
        else:
            # This path means geteuid() check passed (e.g. tests run as root)
            self.assertIn("Deletion cancelled by user.", process.stdout)
            self.assertEqual(process.returncode, 0)

if __name__ == '__main__':
    unittest.main()
