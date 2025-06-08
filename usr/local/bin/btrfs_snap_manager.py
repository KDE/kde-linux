#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
from datetime import datetime
import shutil

SNAPSHOT_DIR = os.environ.get('BTRFS_SNAP_MANAGER_TEST_SNAPSHOT_DIR', "/home/.snapshots")
SNAPSHOT_PREFIX = "home-"

def run_command(command_list, check=True, capture_output=False, text=True, shell=False):
    if shell:
        command_to_run = " ".join(command_list)
    else:
        command_to_run = command_list
    try:
        process = subprocess.run(
            command_to_run,
            check=check,
            capture_output=capture_output,
            text=text,
            shell=shell
        )
        return process
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {command_to_run}", file=sys.stderr)
        if e.stderr: print(f"Stderr: {e.stderr}", file=sys.stderr)
        if e.stdout: print(f"Stdout: {e.stdout}", file=sys.stderr)
        sys.exit(e.returncode)
    except FileNotFoundError:
        print(f"Error: Command '{command_list[0]}' not found. Is it installed and in PATH?", file=sys.stderr)
        sys.exit(1)

def confirm_action(prompt):
    while True:
        try:
            response = input(f"{prompt} [y/N]: ").lower().strip()
            if response == 'y':
                return True
            elif response == 'n' or response == '':
                return False
            else:
                print("Invalid input. Please enter 'y' or 'n'.")
        except EOFError:
            return False # Default to No on EOF

def list_snapshots(args):
    print(f"Available snapshots in {SNAPSHOT_DIR}:")
    try:
        entries = sorted(os.listdir(SNAPSHOT_DIR))
    except FileNotFoundError:
        print(f"Error: Snapshot directory {SNAPSHOT_DIR} not found.", file=sys.stderr)
        sys.exit(1)
    except PermissionError:
        print(f"Error: Permission denied accessing {SNAPSHOT_DIR}.", file=sys.stderr)
        sys.exit(1)

    found_snapshots = False
    for entry in entries:
        if entry.startswith(SNAPSHOT_PREFIX) and os.path.isdir(os.path.join(SNAPSHOT_DIR, entry)):
            found_snapshots = True
            try:
                timestamp_str = entry[len(SNAPSHOT_PREFIX):]
                creation_time = datetime.strptime(timestamp_str, '%Y-%m-%d_%H-%M-%S')
                print(f"  - {entry} (Created: {creation_time.strftime('%Y-%m-%d %H:%M:%S')})")
            except ValueError:
                print(f"  - {entry} (Could not parse creation time)")
    if not found_snapshots:
        print("  No snapshots found.")

def restore_snapshot(args):
    snapshot_name = args.snapshot_name
    target_path = args.target_path.strip("/")
    destination_path = args.destination_path

    snapshot_full_path = os.path.join(SNAPSHOT_DIR, snapshot_name)
    source_item_path = os.path.join(snapshot_full_path, target_path)

    if not os.path.exists(snapshot_full_path) or not os.path.isdir(snapshot_full_path):
        print(f"Error: Snapshot '{snapshot_name}' not found or is not a directory in {SNAPSHOT_DIR}.", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(source_item_path):
        print(f"Error: Target path '{target_path}' not found within snapshot '{snapshot_name}'.", file=sys.stderr)
        sys.exit(1)

    if destination_path:
        dest_dir_to_check = destination_path
        if os.path.isfile(source_item_path) and not destination_path.endswith('/'):
             dest_dir_to_check = os.path.dirname(destination_path)

        if dest_dir_to_check and not os.path.exists(dest_dir_to_check):
            os.makedirs(dest_dir_to_check, exist_ok=True)
        effective_destination = destination_path
    else:
        original_base_path = os.environ.get("HOME", "/home")
        effective_destination = os.path.join(original_base_path, target_path)

        effective_dest_parent = os.path.dirname(effective_destination)
        if effective_dest_parent and not os.path.exists(effective_dest_parent):
            os.makedirs(effective_dest_parent, exist_ok=True)

        if os.path.exists(effective_destination):
            if not confirm_action(f"'{effective_destination}' already exists. Overwrite and backup original?"):
                print("Restore cancelled by user.")
                return
            backup_name = f"{effective_destination}.original.{datetime.now().strftime('%Y%m%d%H%M%S')}"
            print(f"Backing up existing '{effective_destination}' to '{backup_name}'...")
            try:
                os.rename(effective_destination, backup_name)
            except OSError as e:
                print(f"Warning: os.rename failed for backup: {e}. Trying copy+delete.", file=sys.stderr)
                try:
                    if os.path.isdir(effective_destination):
                        run_command(['cp', '-ar', effective_destination, backup_name])
                        run_command(['rm', '-rf', effective_destination])
                    else:
                        run_command(['cp', '-a', effective_destination, backup_name])
                        run_command(['rm', '-f', effective_destination])
                except Exception as backup_e:
                    print(f"Error: Failed to backup '{effective_destination}': {backup_e}. Aborting restore.", file=sys.stderr)
                    sys.exit(1)

    print(f"Restoring '{source_item_path}' to '{effective_destination}'...")
    try:
        rsync_cmd = ['rsync', '-a']
        rsync_source = source_item_path
        if os.path.isdir(source_item_path):
            rsync_source = source_item_path.rstrip('/') + '/'

        rsync_target = effective_destination
        if os.path.isdir(effective_destination) and not effective_destination.endswith('/'):
             rsync_target += '/'

        rsync_cmd.extend([rsync_source, rsync_target])

        run_command(rsync_cmd)
        print("Restore successful.")
    except Exception as e:
        print(f"Error during restore: {e}", file=sys.stderr) # Should be caught by run_command for rsync
        sys.exit(1)


def delete_snapshot(args):
    snapshot_name = args.snapshot_name
    snapshot_full_path = os.path.join(SNAPSHOT_DIR, snapshot_name)

    if not os.path.exists(snapshot_full_path) or not os.path.isdir(snapshot_full_path):
        print(f"Error: Snapshot '{snapshot_name}' not found in {SNAPSHOT_DIR}.", file=sys.stderr)
        sys.exit(1)

    if os.geteuid() != 0:
        print("Error: Deleting snapshots requires root privileges. Please run with sudo.", file=sys.stderr)
        sys.exit(1)

    if not confirm_action(f"Are you sure you want to delete snapshot '{snapshot_name}'? This action is irreversible."):
        print("Deletion cancelled by user.")
        return

    print(f"Deleting snapshot '{snapshot_full_path}'...")
    try:
        run_command(['btrfs', 'subvolume', 'delete', snapshot_full_path])
        print(f"Snapshot '{snapshot_name}' deleted successfully.")
    except FileNotFoundError:
        print("Error: 'btrfs' command not found. Is Btrfs progs installed?", file=sys.stderr)
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        description="Manage Btrfs snapshots for /home.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('--version', action='version', version='%(prog)s 0.1.1')

    subparsers = parser.add_subparsers(title="Commands", dest="command", required=True)

    list_parser = subparsers.add_parser("list", help="List available snapshots in the configured snapshot directory.")
    list_parser.set_defaults(func=list_snapshots)

    restore_parser = subparsers.add_parser(
        "restore",
        help="Restore a file or directory from a snapshot.\n"
             "Example:\n"
             "  %(prog)s home-2023-10-26_12-00-00 Documents/MyFile.txt\n"
             "  %(prog)s home-2023-10-26_12-00-00 Documents/MyFolder RestoredFolder/\n"
             "  %(prog)s home-2023-10-26_12-00-00 MyFile.txt /tmp/MyRestoredFile.txt",
        formatter_class=argparse.RawTextHelpFormatter
    )
    restore_parser.add_argument("snapshot_name", help="Name of the snapshot (e.g., home-YYYY-MM-DD_HH-MM-SS)")
    restore_parser.add_argument("target_path", help="Relative path of the file/directory within the snapshot to restore")
    restore_parser.add_argument(
        "destination_path",
        nargs="?",
        help="Optional: Path to restore to. If omitted, restores to original location (relative to HOME env var), backing up existing items."
    )
    restore_parser.set_defaults(func=restore_snapshot)

    delete_parser = subparsers.add_parser(
        "delete",
        help="Delete a snapshot. Requires sudo.\n"
             "Example: sudo %(prog)s home-2023-10-25_10-00-00",
        formatter_class=argparse.RawTextHelpFormatter
    )
    delete_parser.add_argument("snapshot_name", help="Name of the snapshot to delete")
    delete_parser.set_defaults(func=delete_snapshot)

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    args = parser.parse_args()
    args.func(args)

if __name__ == "__main__":
    main()
