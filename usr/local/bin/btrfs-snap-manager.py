#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
from datetime import datetime

SNAPSHOT_DIR = "/home/.snapshots"
SNAPSHOT_PREFIX = "home-"

def run_command(command, check=True, capture_output=False, text=True):
    """Helper function to run shell commands."""
    try:
        process = subprocess.run(
            command,
            check=check,
            capture_output=capture_output,
            text=text,
            shell=isinstance(command, str) # Allow string command if shell=True
        )
        return process
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {' '.join(command) if isinstance(command, list) else command}", file=sys.stderr)
        print(f"Stderr: {e.stderr}", file=sys.stderr)
        sys.exit(e.returncode)
    except FileNotFoundError:
        print(f"Error: Command '{command[0]}' not found. Is it installed and in PATH?", file=sys.stderr)
        sys.exit(1)


def list_snapshots(args):
    """Lists all available snapshots."""
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
                # Attempt to get creation time from filename (format: home-YYYY-MM-DD_HH-MM-SS)
                timestamp_str = entry[len(SNAPSHOT_PREFIX):]
                creation_time = datetime.strptime(timestamp_str, '%Y-%m-%d_%H-%M-%S')
                print(f"  - {entry} (Created: {creation_time.strftime('%Y-%m-%d %H:%M:%S')})")
            except ValueError:
                # If parsing fails, just print the name
                print(f"  - {entry} (Could not parse creation time)")
    if not found_snapshots:
        print("  No snapshots found.")

def confirm_action(prompt):
    """Asks user for confirmation."""
    while True:
        response = input(f"{prompt} [y/N]: ").lower().strip()
        if response == 'y':
            return True
        elif response == 'n' or response == '':
            return False
        else:
            print("Invalid input. Please enter 'y' or 'n'.")

def restore_snapshot(args):
    """Restores a file/directory from a snapshot."""
    snapshot_name = args.snapshot_name
    target_path = args.target_path.strip("/") # Remove leading/trailing slashes
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
        # Ensure destination directory exists if it's a directory path
        if destination_path.endswith('/') and not os.path.isdir(destination_path):
            os.makedirs(destination_path, exist_ok=True)
        elif not destination_path.endswith('/') and not os.path.exists(os.path.dirname(destination_path) or '.'):
             os.makedirs(os.path.dirname(destination_path) or '.', exist_ok=True)
        effective_destination = destination_path
    else:
        # Restore to original location
        # This assumes /home is the root for paths within the snapshot
        original_base_path = "/home" # This might need to be more dynamic if /home is not always the case
        effective_destination = os.path.join(original_base_path, target_path)

        if os.path.exists(effective_destination):
            if not confirm_action(f"'{effective_destination}' already exists. Overwrite and backup original?"):
                print("Restore cancelled by user.")
                return
            backup_name = f"{effective_destination}.original.{datetime.now().strftime('%Y%m%d%H%M%S')}"
            print(f"Backing up existing '{effective_destination}' to '{backup_name}'...")
            try:
                # Using os.rename for atomic move if possible, otherwise fallback or copy
                os.rename(effective_destination, backup_name)
            except OSError as e:
                print(f"Warning: Could not move original to backup location using os.rename: {e}. Trying copy+delete.", file=sys.stderr)
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


    # Ensure parent directory of effective_destination exists if restoring a single file to a new path
    if not os.path.isdir(effective_destination) and not os.path.exists(os.path.dirname(effective_destination) or '.'):
        os.makedirs(os.path.dirname(effective_destination) or '.', exist_ok=True)


    print(f"Restoring '{source_item_path}' to '{effective_destination}'...")
    try:
        # Using rsync to preserve attributes and handle directories/files
        cmd = ['rsync', '-a', '--delete' if os.path.isdir(source_item_path) and os.path.exists(effective_destination) else '', source_item_path, effective_destination]
        # If source is a directory, rsync needs a trailing slash to copy contents
        if os.path.isdir(source_item_path) and not source_item_path.endswith('/'):
            cmd = ['rsync', '-ar', '--delete' if os.path.exists(effective_destination) else '', source_item_path + '/', effective_destination if os.path.isdir(effective_destination) else os.path.dirname(effective_destination)+'/']


        # Refined rsync command
        rsync_cmd = ['rsync', '-a']
        # If the source is a directory, append a slash to copy its content
        # otherwise, rsync copies the directory itself.
        rsync_source_path = source_item_path
        if os.path.isdir(source_item_path):
            rsync_source_path = os.path.join(source_item_path, '') # Adds trailing slash

        # If destination exists and is a directory, restore into it.
        # Otherwise, restore to the path given.
        rsync_dest_path = effective_destination
        if os.path.isdir(effective_destination):
             rsync_dest_path = os.path.join(effective_destination, '') # Adds trailing slash if it's a dir
        elif os.path.isfile(effective_destination) and os.path.isdir(source_item_path):
            print(f"Error: Cannot overwrite non-directory '{effective_destination}' with directory '{source_item_path}'.", file=sys.stderr)
            sys.exit(1)


        # If restoring a directory to a path that will become the directory itself
        if os.path.isdir(source_item_path):
            # if destination_path is provided and it's not explicitly a directory (no trailing /)
            # rsync will create a directory named as the last component of destination_path
            # and put content into it.
            # If destination_path has a trailing /, rsync will copy content directly into destination_path
            if args.destination_path and not args.destination_path.endswith('/'):
                 rsync_cmd.extend([rsync_source_path, os.path.dirname(rsync_dest_path) or '.'])
            else: # restore into the target dir, or to original location
                 rsync_cmd.extend([rsync_source_path, rsync_dest_path])
        else: # it's a file
            # if destination is a directory, copy file into it
            if os.path.isdir(rsync_dest_path):
                rsync_cmd.extend([rsync_source_path, rsync_dest_path])
            else: # copy file to the specified path (potentially overwriting)
                rsync_cmd.extend([rsync_source_path, rsync_dest_path])


        print(f"Executing: {' '.join(rsync_cmd)}")
        run_command(rsync_cmd)
        print("Restore successful.")
    except Exception as e:
        print(f"Error during restore: {e}", file=sys.stderr)
        sys.exit(1)


def delete_snapshot(args):
    """Deletes a snapshot."""
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
        # Btrfs subvolume delete command
        run_command(['btrfs', 'subvolume', 'delete', snapshot_full_path])
        print(f"Snapshot '{snapshot_name}' deleted successfully.")
    except subprocess.CalledProcessError as e:
        # Already handled by run_command, but we could add more specific error messages here
        print(f"Failed to delete snapshot '{snapshot_name}'. Btrfs command failed.", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print("Error: 'btrfs' command not found. Is Btrfs progs installed?", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Manage Btrfs snapshots for /home.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    subparsers = parser.add_subparsers(title="Commands", dest="command", required=True)

    # List subcommand
    list_parser = subparsers.add_parser("list", help="List available snapshots in /home/.snapshots/")
    list_parser.set_defaults(func=list_snapshots)

    # Restore subcommand
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
        help="Optional: Path to restore to. If omitted, restores to original location in /home, backing up existing items."
    )
    restore_parser.set_defaults(func=restore_snapshot)

    # Delete subcommand
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
