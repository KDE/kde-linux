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
use libbtrfsutil::{
    CreateSnapshotOptions, CreateSubvolumeOptions, DeleteSubvolumeOptions, is_subvolume,
};

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

fn run(root: &Path) -> Result<(), Box<dyn Error>> {
    env::set_current_dir(root)?;

    let system_path = root.join("@system");
    if system_path.exists() {
        println!("@system exists already. Skipping migration.");
        return Ok(());
    }

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

    return Ok(());
}

fn run_v3(root: &Path) -> Result<(), Box<dyn Error>> {
    let system_home = root.join("@system/home");
    let system_home_tmp = root.join("@system/home.v3tmp");
    let system_home_old = root.join("@system/home.v3old");
    let _ = Command::new("plymouth")
        .arg("display-message")
        .arg("--text=Migrating to v3 rootfs. This will take a while.")
        .status();
    println!("Migrating @system/home from subvolume to regular directory with per-user subvolumes");

    // Clean up any leftover staging dirs from a previous failed run
    if system_home_tmp.exists() {
        println!("Cleaning up leftover {system_home_tmp:?} from previous run");
        fs::remove_dir_all(&system_home_tmp)?;
    }
    if system_home_old.exists() {
        println!("Cleaning up leftover {system_home_old:?} from previous run");
        DeleteSubvolumeOptions::new()
            .recursive(true)
            .delete(&system_home_old)
            .map_err(|e| format!("Failed to delete leftover {system_home_old:?}: {e:?}"))?;
    }

    // Stage into a sibling directory so that if we crash mid-way, @system/home is still a subvolume
    // and the next boot will retry the migration cleanly.
    fs::create_dir(&system_home_tmp)?;
    for entry in fs::read_dir(&system_home)? {
        let entry = entry?;
        let src = entry.path();
        if !src.is_dir() {
            continue;
        }
        let dst = system_home_tmp.join(entry.file_name());
        println!("Creating user subvolume at {dst:?}");
        CreateSubvolumeOptions::new()
            .create(&dst)
            .map_err(|e| format!("Failed to create subvolume {dst:?}: {e:?}"))?;

        // Copy everything including nested subvolume dirs (we'll replace those with snapshots after)
        let cp_result = Command::new("cp")
            .arg("--recursive")
            .arg("--archive")
            .arg("--reflink=auto")
            .arg(format!("{}/.", src.display()))
            .arg(format!("{}/.", dst.display()))
            .status()
            .expect("Failed to copy user home");
        if !cp_result.success() {
            return Err(format!("Failed to copy {src:?} to {dst:?}").into());
        }

        // Replace any nested subvolume dirs (which cp copied as plain dirs) with proper snapshots
        for nested in fs::read_dir(&src)? {
            let nested = nested?;
            let nested_src = nested.path();
            if is_subvolume(&nested_src)? {
                let nested_dst = dst.join(nested.file_name());
                println!("Snapshotting nested subvolume {nested_src:?} -> {nested_dst:?}");
                fs::remove_dir_all(&nested_dst)?;
                CreateSnapshotOptions::new()
                    .recursive(true)
                    .create(&nested_src, &nested_dst)
                    .map_err(|e| {
                        format!("Failed to snapshot {nested_src:?} to {nested_dst:?}: {e:?}")
                    })?;
            }
        }
    }

    println!("Renaming {system_home:?} to {system_home_old:?}");
    fs::rename(&system_home, &system_home_old)?;

    println!("Renaming {system_home_tmp:?} to {system_home:?}");
    if let Err(e) = fs::rename(&system_home_tmp, &system_home) {
        eprintln!("Fatal: failed to rename {system_home_tmp:?} to {system_home:?}: {e}");
        eprintln!("Restoring original home subvolume from {system_home_old:?}");
        fs::rename(&system_home_old, &system_home)
            .map_err(|re| format!("CRITICAL: failed to restore original home: {re}. System may be unbootable. Original home is at {system_home_old:?}"))?;
        return Err(format!("Migration failed, original home restored: {e}").into());
    }

    // Only delete the old subvolume once we know the new layout is in place
    println!("Deleting old home subvolume {system_home_old:?}");
    let _ = DeleteSubvolumeOptions::new()
        .recursive(true)
        .delete(&system_home_old)
        .map_err(|e| {
            eprintln!("Warning: failed to delete old home subvolume {system_home_old:?}: {e}");
            eprintln!("The migration succeeded but {system_home_old:?} can be manually deleted.");
        });

    Ok(())
}

fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Usage: {} system_mount", args[0]);
        println!("Migrates a legacy subvol (pre-May-2025) to v2 rootfs");
        return Err("Not enough arguments".into());
    }

    let root = Path::new(&args[1]);
    let system_path = root.join("@system");

    let (msg, result) = if system_path.exists() {
        println!("Migrating to v3 rootfs.");
        (
            "Migrating to v3 rootfs. This will take a while.",
            run_v3(root),
        )
    } else {
        println!("Migrating to v2 rootfs. This will take a while.");
        ("Migrating to v2 rootfs. This will take a while.", run(root))
    };
    let _ = msg; // used for context above

    match result {
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
