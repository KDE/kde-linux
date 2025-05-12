// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

use std::{env, error::Error, fs::{self}, io::{self, Write}, path::Path, process::Command, vec};

use libbtrfsutil::{CreateSnapshotOptions, CreateSubvolumeOptions, DeleteSubvolumeOptions};
use fstab::FsTab;
use dialoguer::{self, Confirm};

fn run(root: &Path, usr: &Path) -> Result<(), Box<dyn Error>> {
    env::set_current_dir(root)?;

    let system_path = root.join("@system");
    if system_path.exists() {
        println!("@system exists already. Skipping migration.");
        return Ok(());
    }

    let import_path = root.join("@system.import");
    if import_path.exists() {
        println!("@system.import exists. Deleting it.");
        match DeleteSubvolumeOptions::new().recursive(true).delete(&import_path) {
            Ok(_) => println!("Deleted subvolume: {import_path:?}"),
            Err(error) => println!("Problem deleting subvolume {import_path:?}: {error:?}")
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
        let _ = Command::new("plymouth")
            .arg("deactivate")
            .status();

        println!("Found {concerning_fstab_entries} concerning fstab entries. This suggests you have a more complicated fstab setup that we cannot auto-migrate. \
            If nothing critically important is managed by fstab you can let the auto-migration run. If you have entries that are required for the system to boot you should manually migrate to @system.");
        // TODO: add wiki link to migration instructions
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

    let mut subvolumes_to_backup = vec![];

    for dir in ["etc", "var"] {
        let lower_path = usr.join("share/factory").join(dir);
        println!("Copying {lower_path:?} to {}", import_path.join(dir).display());
        let lower_result = Command::new("cp")
            .arg("--recursive")
            .arg("--archive")
            .arg("--reflink=auto")
            .arg(&lower_path)
            .arg(dir)
            .status()
            .expect("failed to execute cp for lower dir");
        if !lower_result.success() {
            println!("Failed to copy lower dir {lower_path:?} to {dir:?}");
            return Err("Failed to copy lower dir".into());
        }

        let dir_path = root.join(format!("@{dir}-overlay/upper"));
        println!("Copying {dir_path:?} to {}", import_path.join(dir).display());
        let upper_result = Command::new("cp")
            .arg("--recursive")
            .arg("--archive")
            .arg("--reflink=auto")
            .arg(&dir_path)
            .arg(dir)
            .status().expect("Failed to copy upper dir");
        if !upper_result.success() {
            println!("Failed to copy upper dir {dir_path:?} to {dir:?}");
            return Err("Failed to copy upper dir".into());
        }

        subvolumes_to_backup.push(format!("@{dir}-overlay"));
    }

    let subvol_targets = [("@home", "home"), ("@root", "root"), ("@snap", "snap"), ("@containers", "var/lib/containers"), ("@docker", "var/lib/docker")];

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
                if dir != Path::new("") && !dir.exists() { // bit crap but parent of a relative path is the empty path.
                    println!("create_dir {dir:?}");
                    fs::create_dir(dir)?;
                }
            },
            None => {
                println!("No parent directory for {target_path:?}");
            },
        }

        CreateSnapshotOptions::new()
            .recursive(true)
            .create(root.join(subvol), Path::new(target))?;

        subvolumes_to_backup.push(subvol.to_string());
    }

    println!("Renaming {import_path:?} to {system_path:?}");
    fs::rename(import_path, system_path)?; // fatal problem

    for subvol in subvolumes_to_backup {
        let from = root.join(&subvol);
        let to = root.join(subvol + ".backup");
        println!("Archiving {from:?} to {to:?}");
        let _ = fs::rename(from, to); // not a fatal problem
    }


    return Ok(());
}

fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 3 {
        println!("Usage: {} system_mount usr_mount", args[0]);
        println!("Migrates a legacy subvol (pre-May-2025) to v2 rootfs");
        return Err("Not enough arguments".into());
    }

    println!("Migrating to v2 rootfs. This will take a while.");

    let root = Path::new(&args[1]);
    let usr = Path::new(&args[2]);

    match run(root, usr) {
        Ok(_) => {
            // Reactivate in case we deactivated it earlier
            let _ = Command::new("plymouth").arg("reactivate").status();
            Ok(())
        }
        Err(e) => {
            // Quit plymouth if there was a fatal problem so the user can see the output
            Command::new("plymouth")
                .arg("quit")
                .status()
                .expect("failed to execute plymouth reactivate");
            Err(e)
        }
    }
}
