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
use dialoguer::Confirm;
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
                eprintln!("Invalid version number in subvolume name: {name} -- {version}");
            }
        }
    }

    candidate.map(|c| c.path)
}

fn run(root: &Path) -> Result<(), Box<dyn Error>> {
    env::set_current_dir(root)?;

    let system_path = root.join("@system");
    if system_path.exists() {
        return Ok(());
    }

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
        match DeleteSubvolumeOptions::new()
            .recursive(true)
            .delete(&import_path)
        {
            Ok(_) => {}
            Err(error) => eprintln!("Problem deleting subvolume {import_path:?}: {error:?}"),
        }
    }
    CreateSubvolumeOptions::new()
        .create(&import_path)
        .map_err(|error| format!("Problem creating subvolume {import_path:?}: {error:?}"))?;

    env::set_current_dir(&import_path)?;

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
        eprintln!(
            "Found {concerning_fstab_entries} concerning fstab entries. This suggests you have a more complicated fstab setup that we cannot auto-migrate.\n\
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
            eprintln!("Failed to mount {}", compose_dir.display());
            return Err("Failed to mount compose dir".into());
        }
        defer! {
            let _ = Command::new("umount").arg(&compose_dir).status();
        }

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
            eprintln!("Failed to copy upper dir {compose_dir:?} to {dir:?}");
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
        let target_path = Path::new(target);

        if target_path.exists() {
            fs::remove_dir_all(target_path)?;
        }

        if let Some(dir) = target_path.parent() {
            if dir != Path::new("") && !dir.exists() {
                fs::create_dir(dir)?;
            }
        }

        CreateSnapshotOptions::new()
            .recursive(true)
            .create(root.join(subvol), Path::new(target))?;
    }

    fs::rename(import_path, system_path)?;
    Ok(())
}

fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: {} system_mount", args[0]);
        eprintln!("Migrates a legacy subvol (pre-May-2025) to v2 rootfs");
        return Err("Not enough arguments".into());
    }

    let root = Path::new(&args[1]);

    match run(root) {
        Ok(_) => {
            let _ = Command::new("plymouth").arg("show-splash").status();
            Ok(())
        }
        Err(e) => {
            let _ = Command::new("plymouth").arg("quit").status();
            Err(e)
        }
    }
}
