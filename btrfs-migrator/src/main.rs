// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

use std::{
    env,
    error::Error,
    fs::{self},
    io::{self, Write},
    path::{Path, PathBuf},
    process::Command,
};
#[macro_use(defer)]
extern crate scopeguard;
use dialoguer::{self, Confirm};
use fstab::FsTab;
use libbtrfsutil::{CreateSnapshotOptions, CreateSubvolumeOptions, DeleteSubvolumeOptions};

fn find_rootfs_v1(root: &Path) -> Option<PathBuf> {
    let subvols = fs::read_dir(root).ok()?;

    struct Candidate {
        path: PathBuf,
        version: u64,
    }

    let mut candidate: Option<Candidate> = None;

    for entry in subvols {
        let entry = entry.ok()?;
        let path = entry.path();
        let file_name = entry.file_name();
        let name = file_name.to_string_lossy().to_string();
        if !name.starts_with("@kde-linux_") {
            continue;
        }
        if !path.join("etc").exists() {
            // This is not a useful/valid rootfs v1 subvolume.
            continue;
        }
        let mut parts = name.splitn(2, '_');
        let _prefix = parts.next().unwrap();
        let version = parts.next().unwrap();
        match version.parse::<u64>() {
            Ok(version) => {
                if candidate.is_none() || candidate.as_ref().unwrap().version < version {
                    candidate = Some(Candidate { path, version });
                }
            }
            Err(_) => {
                println!("Invalid version number in subvolume name: {name} -- {version}");
            }
        }
    }

    match candidate {
        Some(c) => {
            println!(
                "Found legacy rootfs v1 at {:?} with version {}",
                c.path, c.version
            );
            Some(c.path)
        }
        None => {
            println!("No legacy rootfs v1 found.");
            None
        }
    }
}

fn needs_rootfsv3_migration(root: &Path) -> bool {
    // Check if @home subvolume exists
    let home_subvol = root.join("@home");
    if !home_subvol.exists() {
        println!("@home subvolume does not exist - RootFSv3 migration needed");
        return true;
    }

    // Check if @home/.snapshots subvolume exists
    let home_snapshots = home_subvol.join(".snapshots");
    if !home_snapshots.exists() {
        println!("@home/.snapshots subvolume does not exist - RootFSv3 migration needed");
        return true;
    }

    false
}

fn migrate_rootfsv3(root: &Path) -> Result<(), Box<dyn Error>> {
    println!("Starting RootFSv3 migration");

    let _ = Command::new("plymouth")
    .arg("display-message")
    .arg("--text=Migrating to v3 rootfs. Setting up @home structure.")
    .status();

    let home_subvol = root.join("@home");
    let home_snapshots = home_subvol.join(".snapshots");

    // Create @home subvolume if it doesn't exist
    if !home_subvol.exists() {
        println!("Creating @home subvolume");
        CreateSubvolumeOptions::new()
        .create(&home_subvol)
        .map_err(|error| format!("Problem creating @home subvolume: {error:?}"))?;
    }

    // Create @home/.snapshots subvolume if it doesn't exist
    if !home_snapshots.exists() {
        println!("Creating @home/.snapshots subvolume");
        CreateSubvolumeOptions::new()
        .create(&home_snapshots)
        .map_err(|error| format!("Problem creating @home/.snapshots subvolume: {error:?}"))?;

        // Set proper permissions for snapper
        let _ = Command::new("chmod")
        .arg("755")
        .arg(&home_snapshots)
        .status();
    }

    // Check if there's existing home data that needs to be migrated
    let system_home = root.join("@system/home");
    if system_home.exists() {
        println!("Found existing home data in @system/home, checking if migration is needed");

        // Check if @home is empty (excluding .snapshots which we just created)
        let home_is_empty = fs::read_dir(&home_subvol)
        .map(|mut entries| entries.next().is_none())
        .unwrap_or(true);

        if home_is_empty {
            println!("Migrating existing home data from @system/home to @home");

            let _ = Command::new("plymouth")
            .arg("display-message")
            .arg("--text=Migrating home data to new structure.")
            .status();

            // Use rsync to copy data preserving permissions and attributes
            let rsync_result = Command::new("rsync")
            .arg("-aAX")
            .arg("--progress")
            .arg(format!("{}/", system_home.to_string_lossy()))
            .arg(format!("{}/", home_subvol.to_string_lossy()))
            .status()?;

            if !rsync_result.success() {
                println!("Warning: Failed to migrate home data with rsync, trying cp as fallback");

                // Fallback to cp
                let cp_result = Command::new("cp")
                .arg("--recursive")
                .arg("--archive")
                .arg("--reflink=auto")
                .arg("--no-target-directory")
                .arg(&system_home)
                .arg(&home_subvol)
                .status()?;

                if !cp_result.success() {
                    println!("Warning: Failed to migrate home data with cp as well");
                }
            }
        } else {
            println!("@home already contains data, skipping home data migration");
        }
    }

    println!("RootFSv3 migration completed successfully");
    Ok(())
}

fn run(root: &Path) -> Result<(), Box<dyn Error>> {
    env::set_current_dir(root)?;

    let system_path = root.join("@system");

    // Check if we need RootFSv2 migration
    if !system_path.exists() {
        println!("@system does not exist, performing RootFSv2 migration");

        // Wait for devices to settle down a bit, otherwise we risk breaking plymouth and printing into the void, leaving
        // the user without any indication what is going on.
        // We do this relatively late in the transition progress so it doesn't unnecessarily delay regular boots.
        let _ = Command::new("udevadm")
        .arg("settle")
        .arg("--timeout=8")
        .status();

        let _ = Command::new("plymouth")
        .arg("display-message")
        .arg("--text=Migrating to v2 rootfs. Can take a while.")
        .status();

        let import_path = root.join("@system.import");
        if import_path.exists() {
            println!("@system.import exists. Deleting it.");
            match DeleteSubvolumeOptions::new()
            .recursive(true)
            .delete(&import_path)
            {
                Ok(_) => println!("Deleted subvolume: {import_path:?}"),
                Err(error) => println!("Problem deleting subvolume {import_path:?}: {error:?}"),
            }
        }
        CreateSubvolumeOptions::new()
        .create(&import_path)
        .map_err(|error| format!("Problem creating subvolume {import_path:?}: {error:?}"))?;

        env::set_current_dir(&import_path)?;
        println!("Current directory: {:?}", env::current_dir()?);

        // May or may not exist. Don't trip over it!
        let fstab = FsTab::new(&root.join("@etc-overlay/upper/fstab"));
        let mut concerning_fstab_entries = 0;
        for entry in fstab.get_entries().unwrap_or_default() {
            if entry.vfs_type != "swap" {
                concerning_fstab_entries += 1;
            }
        }
        if concerning_fstab_entries > 0 {
            let _ = Command::new("plymouth").arg("hide-splash").status();

            let _ = qr2term::print_qr("https://community.kde.org/KDE_Linux/RootFSv2");

            println!(
                "Found {concerning_fstab_entries} concerning fstab entries. This suggests you have a more complicated fstab setup that we cannot auto-migrate. \
If nothing critically important is managed by fstab you can let the auto-migration run. If you have entries that are required for the system to boot you should manually migrate to @system."
            );
            io::stdout().flush().unwrap();

            let migrate = Confirm::new()
            .with_prompt("Do you want to continue with auto-migration?")
            .interact()
            .unwrap();

            if !migrate {
                Command::new("systemctl")
                .arg("reboot")
                .status()
                .expect("failed to execute systemctl reboot");
                return Err("Concerning fstab entries found".into());
            }
        }

        let rootfs_v1 = match find_rootfs_v1(root) {
            Some(path) => path,
            None => return Err("No legacy rootfs v1 found. Migration impossible.".into()),
        };

        for dir in ["etc", "var"] {
            let compose_dir = rootfs_v1.join(dir);

            let mount_result = Command::new("mount")
            .arg("--verbose")
            .arg("--types")
            .arg("overlay")
            .arg("--options")
            .arg(format!(
                "ro,lowerdir={},upperdir={},workdir={},index=off,metacopy=off",
                compose_dir.to_string_lossy(),
                         root.join(format!("@{dir}-overlay/upper")).to_string_lossy(),
                         root.join(format!("@{dir}-overlay/work")).to_string_lossy()
            ))
            .arg("overlay")
            .arg(&compose_dir)
            .status()
            .expect("Failed to mount overlay for etc/var");
            if !mount_result.success() {
                println!("Failed to mount {}", compose_dir.display());
                return Err("Failed to mount compose dir".into());
            }
            defer! {
                println!("Unmounting overlay for {}", dir);
                Command::new("umount")
                .arg(&compose_dir)
                .status()
                .expect("Failed to unmount overlay for etc/var");
            }

            println!(
                "Copying {} to {}",
                compose_dir.display(),
                     import_path.join(dir).display()
            );
            let cp_result = Command::new("cp")
            .arg("--recursive")
            .arg("--archive")
            .arg("--reflink=auto")
            .arg("--no-target-directory")
            .arg(&compose_dir)
            .arg(dir)
            .status()
            .expect("Failed to copy upper dir");
            if !cp_result.success() {
                println!("Failed to copy upper dir {compose_dir:?} to {dir:?}");
                return Err("Failed to copy upper dir".into());
            }
        }

        let subvol_targets = [
            ("@home", "home"),
            ("@root", "root"),
            ("@snap", "snap"),
            ("@containers", "var/lib/containers"),
            ("@docker", "var/lib/docker"),
        ];

        for (subvol, target) in subvol_targets {
            println!("Snapshotting {} to {}", root.join(subvol).display(), target);
            let target_path = Path::new(target);

            // Inside var the target_path may already exist if they predate the subvolumes. Originally contianers and docker were not subvolumes.
            // Make sure to throw the data away before trying to snapshot, otherwise the snapshot will fail.
            if target_path.exists() {
                println!("Removing pre-existing directory {target_path:?}");
                fs::remove_dir_all(target_path)?;
            }

            match target_path.parent() {
                Some(dir) => {
                    if dir != Path::new("") && !dir.exists() {
                        // bit crap but parent of a relative path is the empty path.
                        println!("create_dir {dir:?}");
                        fs::create_dir(dir)?;
                    }
                }
                None => {
                    println!("No parent directory for {target_path:?}");
                }
            }

            CreateSnapshotOptions::new()
            .recursive(true)
            .create(root.join(subvol), Path::new(target))?;
        }

        println!("Renaming {import_path:?} to {system_path:?}");
        fs::rename(import_path, system_path)?; // fatal problem
    } else {
        println!("@system exists, skipping RootFSv2 migration");
    }

    // Check if we need RootFSv3 migration
    if needs_rootfsv3_migration(root) {
        migrate_rootfsv3(root)?;
    } else {
        println!("RootFSv3 structure already exists, skipping v3 migration");
    }

    Ok(())
}

fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Usage: {} system_mount", args[0]);
        println!("Migrates legacy subvols (pre-October-2025) to v3 rootfs");
        return Err("Not enough arguments".into());
    }

    println!("Checking for rootfs migrations. This may take a while.");

    let root = Path::new(&args[1]);

    match run(root) {
        Ok(_) => {
            // Reactivate in case we deactivated it earlier
            let _ = Command::new("plymouth").arg("show-splash").status();
            Ok(())
        }
        Err(e) => {
            // Quit plymouth if there was a fatal problem so the user can see the output
            Command::new("plymouth")
            .arg("quit")
            .status()
            .expect("failed to execute plymouth show-splash");
            Err(e)
        }
    }
}
