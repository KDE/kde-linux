# Btrfs Snapshot Backups

This document describes the automatic Btrfs snapshot backup feature for user home directories and how to manage these snapshots.

## Overview

The system is configured to automatically create read-only snapshots of your `/home` directory. These snapshots can help you recover previous versions of your files or restore accidentally deleted data.

### Snapshot Schedule and Retention
- **Frequency:** Snapshots are taken daily.
- **Naming:** Snapshots are named with a timestamp, e.g., `home-YYYY-MM-DD_HH-MM-SS`, and stored in `/home/.snapshots/`.
- **Retention Policy:**
    - Daily snapshots are kept for 7 days.
    - Weekly snapshots (taken on Sunday) are kept for 4 weeks.
    - Monthly snapshots (taken on the 1st of the month) are kept for 3 months.
- **Pruning:** An automated script runs daily to prune old snapshots according to this retention policy.

## Managing Snapshots (`btrfs-snap-manager.py`)

A command-line tool, `btrfs-snap-manager.py`, is provided to help you list, restore, and delete snapshots.

### Common Commands

**1. List Snapshots**
To see all available snapshots:
```bash
btrfs-snap-manager.py list
```
This will display the snapshot name (which includes the creation timestamp).

**2. Restore Files/Directories**
To restore a file or directory from a snapshot:
```bash
btrfs-snap-manager.py restore <snapshot_name> <path_to_item_in_snapshot> [destination_path]
```
- `<snapshot_name>`: The full name of the snapshot (e.g., `home-2023-10-28_14-30-00`).
- `<path_to_item_in_snapshot>`: The path of the file or directory *inside* the snapshot, relative to your home directory (e.g., `Documents/MyImportantFile.txt`).
- `[destination_path]` (optional):
    - If provided, the item will be restored to this path.
    - If omitted, the item will be restored to its original location in your home directory. If a file or directory with the same name already exists at the original location, the existing item will be backed up with a `.original.TIMESTAMP` suffix before restoring.

Examples:
```bash
# Restore MyFile.txt from a snapshot to its original location
btrfs-snap-manager.py restore home-2023-10-28_14-30-00 Documents/MyFile.txt

# Restore MyFile.txt to a different directory
btrfs-snap-manager.py restore home-2023-10-28_14-30-00 Documents/MyFile.txt RestoredItems/
```
You will be asked for confirmation before any files are restored or overwritten.

**3. Delete Snapshots**
To manually delete a snapshot (e.g., to free up space):
```bash
sudo btrfs-snap-manager.py delete <snapshot_name>
```
- `<snapshot_name>`: The full name of the snapshot to delete.
- **Note:** This command requires `sudo` (administrator) privileges because it modifies Btrfs subvolumes.

You will be asked for confirmation before a snapshot is deleted. Be cautious when deleting snapshots, as this action cannot be undone.

### Getting Help
For more detailed usage instructions for each command:
```bash
btrfs-snap-manager.py --help
btrfs-snap-manager.py list --help
btrfs-snap-manager.py restore --help
btrfs-snap-manager.py delete --help
```

## How to Recover from Data Loss

1.  **Identify the data loss:** Determine which files or directories are missing or need to be reverted.
2.  **Find a suitable snapshot:** Use `btrfs-snap-manager.py list` to find a snapshot taken *before* the data loss occurred. Note the snapshot's name.
3.  **Restore the data:**
    *   If you want to restore to the original location, navigate to the parent directory of the lost item in your terminal.
    *   Use the `btrfs-snap-manager.py restore` command. For example, if you deleted `~/Documents/Report.odt` and want to restore it from `home-2023-10-28_09-00-00`:
        ```bash
        btrfs-snap-manager.py restore home-2023-10-28_09-00-00 Documents/Report.odt
        ```
    *   If you prefer to restore to a temporary location first to inspect the files:
        ```bash
        mkdir ~/RestoredFiles
        btrfs-snap-manager.py restore home-2023-10-28_09-00-00 Documents/Report.odt ~/RestoredFiles/
        ```
4.  **Verify:** Check that your files have been restored correctly.

## Important Considerations
- Snapshots are read-only. You cannot directly modify files within a snapshot.
- Snapshots consume disk space. While the automated pruning helps, be mindful of how many manual snapshots you keep, if any. The `btrfs-snapshot-prune.sh` script only prunes snapshots in `/home/.snapshots/` that follow the `home-YYYY-MM-DD_HH-MM-SS` naming convention.
- This backup system protects against accidental deletion or modification of files within your home directory. It does not protect against hardware failure of the disk itself. Always consider having multiple backup strategies, including off-site backups for critical data.
