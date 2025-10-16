// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2025 Harald Sitter sitter@kde.org
// SPDX-FileCopyrightText: 2025 Hadi Chokr hadichokr@icloud.com

use std::{
    env,
    error::Error,
    fmt,
    fs::{self},
    io::{self, Write},
    os::unix::fs::MetadataExt,
    path::{Path, PathBuf},
    process::Command,
};
use scopeguard;
use dialoguer::{Confirm, theme::ColorfulTheme};
use fstab::FsTab;
use libbtrfsutil::{CreateSnapshotOptions, CreateSubvolumeOptions, DeleteSubvolumeOptions};

// Custom error type for better error handling
#[derive(Debug)]
struct MigrationError {
    message: String,
    context: String,
}

impl fmt::Display for MigrationError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}: {}", self.context, self.message)
    }
}

impl Error for MigrationError {}

impl MigrationError {
    fn new(message: impl Into<String>, context: impl Into<String>) -> Self {
        Self {
            message: message.into(),
            context: context.into(),
        }
    }
}

// Result type alias for cleaner code
type MigrationResult<T> = Result<T, Box<dyn Error>>;

// Configuration and state
struct MigrationContext {
    root_path: PathBuf,
    current_step: u32,
}

impl MigrationContext {
    fn new(root_path: &Path) -> Self {
        Self {
            root_path: root_path.to_path_buf(),
            current_step: 0,
        }
    }

    fn log_step(&mut self, step: &str) {
        self.current_step += 1;
        println!("[STEP {}] {}", self.current_step, step);
    }

    fn log_info(&self, message: &str) {
        println!("    INFO: {}", message);
    }

    fn log_success(&self, message: &str) {
        println!("    SUCCESS: {}", message);
    }

    fn log_warning(&self, message: &str) {
        println!("    WARNING: {}", message);
    }

    fn log_error(&self, message: &str) {
        eprintln!("    ERROR: {}", message);
    }

    fn path(&self, relative: &str) -> PathBuf {
        self.root_path.join(relative)
    }
}

struct LegacyRootFsV1Finder;

impl LegacyRootFsV1Finder {
    fn find_latest(root: &Path) -> MigrationResult<Option<PathBuf>> {
        let subvols = fs::read_dir(root)
            .map_err(|e| MigrationError::new(format!("Failed to read root directory: {}", e), "V1 detection"))?;

        #[derive(Debug)]
        struct Candidate {
            path: PathBuf,
            version: u64,
        }

        let mut candidate: Option<Candidate> = None;

        for entry in subvols {
            let entry = entry.map_err(|e| MigrationError::new(format!("Failed to read directory entry: {}", e), "V1 detection"))?;
            let path = entry.path();
            let name = entry.file_name().to_string_lossy().to_string();

            if !name.starts_with("@kde-linux_") {
                continue;
            }

            if !path.join("etc").exists() {
                // This is not a useful/valid rootfs v1 subvolume.
                continue;
            }

            if let Some(version_str) = name.strip_prefix("@kde-linux_") {
                if let Ok(version) = version_str.parse::<u64>() {
                    if candidate.as_ref().map_or(true, |c| c.version < version) {
                        candidate = Some(Candidate { path, version });
                    }
                } else {
                    println!("    WARNING: Invalid version number in subvolume: {} (version: {})", name, version_str);
                }
            }
        }

        match candidate {
            Some(c) => {
                println!("    FOUND legacy rootfs v1 at {:?} (version {})", c.path, c.version);
                Ok(Some(c.path))
            }
            None => {
                println!("    INFO: No legacy rootfs v1 found");
                Ok(None)
            }
        }
    }
}

struct RootFsV3Checker;

impl RootFsV3Checker {
    fn needs_migration(root: &Path) -> MigrationResult<bool> {
        let home_subvol = root.join("@home");
        if !home_subvol.exists() {
            println!("    INFO: @home subvolume missing - RootFSv3 migration required");
            return Ok(true);
        }

        let home_snapshots = home_subvol.join(".snapshots");
        if !home_snapshots.exists() {
            println!("    INFO: @home/.snapshots subvolume missing - RootFSv3 migration required");
            return Ok(true);
        }

        println!("    INFO: RootFSv3 structure already exists");
        Ok(false)
    }
}

struct SubvolumeHelper;

impl SubvolumeHelper {
    fn is_subvolume(path: &Path) -> bool {
        fs::metadata(path)
            .map(|metadata| metadata.ino() == 256)
            .unwrap_or(false)
    }

    fn create_subvolume(path: &Path) -> MigrationResult<()> {
        CreateSubvolumeOptions::new()
            .create(path)
            .map_err(|e| MigrationError::new(format!("Failed to create subvolume: {}", e), "Subvolume creation").into())
    }

    fn create_snapshot(source: &Path, target: &Path) -> MigrationResult<()> {
        CreateSnapshotOptions::new()
            .recursive(true)
            .create(source, target)
            .map_err(|e| MigrationError::new(format!("Failed to create snapshot: {}", e), "Snapshot creation").into())
    }

    fn delete_subvolume(path: &Path) -> MigrationResult<()> {
        DeleteSubvolumeOptions::new()
            .recursive(true)
            .delete(path)
            .map_err(|e| MigrationError::new(format!("Failed to delete subvolume: {}", e), "Subvolume deletion").into())
    }
}

struct HomeDataMigrator;

impl HomeDataMigrator {
    fn migrate(ctx: &mut MigrationContext) -> MigrationResult<()> {
        ctx.log_step("Migrating home data to RootFSv3 structure");

        let system_home = ctx.path("@system/home");
        let home_subvol = ctx.path("@home");
        let old_home_backup = ctx.path("@oldhome");

        if !system_home.exists() {
            ctx.log_info("No existing home data found in @system/home - nothing to migrate");
            return Ok(());
        }

        ctx.log_info("Found existing home data in @system/home");

        // Determine if home is a subvolume or regular directory
        let home_is_subvolume = SubvolumeHelper::is_subvolume(&system_home);
        ctx.log_info(&format!("@system/home is subvolume: {}", home_is_subvolume));

        Self::display_home_contents(ctx, &system_home)?;
        Self::create_home_backup(ctx, &system_home, &old_home_backup, home_is_subvolume)?;
        Self::remove_old_home_data(ctx, &system_home, home_is_subvolume)?;
        Self::ensure_home_subvolume(ctx, &home_subvol)?;
        Self::transfer_home_data(ctx, &old_home_backup, &home_subvol)?;
        Self::cleanup_backup(ctx, &old_home_backup)?;

        ctx.log_success("Home data migration completed");
        Ok(())
    }

    fn display_home_contents(ctx: &MigrationContext, system_home: &Path) -> MigrationResult<()> {
        ctx.log_info("Contents of @system/home:");
        match fs::read_dir(system_home) {
            Ok(entries) => {
                for entry in entries.flatten() {
                    println!("        {:?}", entry.file_name());
                }
            }
            Err(e) => ctx.log_warning(&format!("Could not list home contents: {}", e)),
        }
        Ok(())
    }

    fn create_home_backup(
        ctx: &MigrationContext,
        system_home: &Path,
        backup_path: &Path,
        is_subvolume: bool,
    ) -> MigrationResult<()> {
        ctx.log_info("Creating backup of existing home data");

        // Remove existing backup if present
        if backup_path.exists() {
            ctx.log_info("Removing existing backup @oldhome");
            SubvolumeHelper::delete_subvolume(backup_path)
                .map_err(|e| MigrationError::new(format!("Failed to remove existing backup: {}", e), "Backup preparation"))?;
        }

        if is_subvolume {
            ctx.log_info("Creating snapshot backup of @system/home");
            SubvolumeHelper::create_snapshot(system_home, backup_path)?;
        } else {
            ctx.log_info("Creating new subvolume and copying directory data");
            SubvolumeHelper::create_subvolume(backup_path)?;
            Self::copy_directory_contents(system_home, backup_path)?;
        }

        ctx.log_success("Backup created successfully");
        Ok(())
    }

    fn remove_old_home_data(ctx: &MigrationContext, system_home: &Path, is_subvolume: bool) -> MigrationResult<()> {
        ctx.log_info("Removing old home data from @system/home");

        if is_subvolume {
            ctx.log_info("Deleting @system/home subvolume");
            SubvolumeHelper::delete_subvolume(system_home)?;
        } else {
            ctx.log_info("Removing @system/home directory contents");
            Self::clear_directory(system_home)?;
        }

        ctx.log_success("Old home data removed");
        Ok(())
    }

    fn ensure_home_subvolume(ctx: &MigrationContext, home_subvol: &Path) -> MigrationResult<()> {
        if !home_subvol.exists() {
            ctx.log_info("Creating @home subvolume");
            SubvolumeHelper::create_subvolume(home_subvol)?;
        }
        Ok(())
    }

    fn transfer_home_data(ctx: &MigrationContext, backup_path: &Path, home_subvol: &Path) -> MigrationResult<()> {
        ctx.log_info("Transferring home data to new @home subvolume");

        let entries = fs::read_dir(backup_path)
            .map_err(|e| MigrationError::new(format!("Failed to read backup: {}", e), "Data transfer"))?;

        for entry in entries {
            let entry = entry?;
            let source_path = entry.path();
            let file_name = entry.file_name();
            let target_path = home_subvol.join(&file_name);

            // Skip .snapshots directory - we'll manage that separately
            if file_name == ".snapshots" {
                continue;
            }

            ctx.log_info(&format!("Moving {:?}", file_name));

            if source_path.is_dir() {
                Self::copy_directory_contents(&source_path, &target_path)?;
            } else {
                // Use external cp to preserve ownership, permissions, xattrs and timestamps.
                let status = Command::new("cp")
                    .arg("--archive")
                    .arg(&source_path)
                    .arg(&target_path)
                    .status()
                    .map_err(|e| MigrationError::new(format!("Failed to copy file: {}", e), "Data transfer"))?;

                if !status.success() {
                    return Err(MigrationError::new("File copy failed", "Data transfer").into());
                }
            }
        }

        ctx.log_success("Home data transferred");
        Ok(())
    }

    fn cleanup_backup(ctx: &MigrationContext, backup_path: &Path) -> MigrationResult<()> {
        ctx.log_info("Cleaning up temporary backup");
        SubvolumeHelper::delete_subvolume(backup_path)?;
        ctx.log_success("Backup cleaned up");
        Ok(())
    }

    fn copy_directory_contents(src: &Path, dst: &Path) -> MigrationResult<()> {
        // Ensure destination exists
        if !dst.exists() {
            fs::create_dir_all(dst)
                .map_err(|e| MigrationError::new(format!("Failed to create directory: {}", e), "Directory copy"))?;
        }

        // Use cp -a to preserve owner, permissions, timestamps and xattrs. Using external tool
        // is acceptable for this system-level migration and avoids reimplementing ownership logic.
        let src_dot = src.join(".");

        let status = Command::new("cp")
            .arg("-a")
            .arg("--reflink=auto")
            .arg(src_dot)
            .arg(dst)
            .status()
            .map_err(|e| MigrationError::new(format!("Failed to copy directory: {}", e), "Directory copy"))?;

        if !status.success() {
            return Err(MigrationError::new("Directory copy failed", "Directory copy").into());
        }

        Ok(())
    }

    fn clear_directory(path: &Path) -> MigrationResult<()> {
        for entry in fs::read_dir(path)
            .map_err(|e| MigrationError::new(format!("Failed to read directory: {}", e), "Directory clearance"))?
        {
            let entry = entry?;
            let path = entry.path();

            if path.is_dir() {
                fs::remove_dir_all(&path)
                    .map_err(|e| MigrationError::new(format!("Failed to remove directory: {}", e), "Directory clearance"))?;
            } else {
                fs::remove_file(&path)
                    .map_err(|e| MigrationError::new(format!("Failed to remove file: {}", e), "Directory clearance"))?;
            }
        }
        Ok(())
    }
}

struct RootFsV3Migrator;

impl RootFsV3Migrator {
    fn migrate(ctx: &mut MigrationContext) -> MigrationResult<()> {
        ctx.log_step("Setting up RootFSv3 structure");

        Self::show_plymouth_message("Migrating to v3 rootfs. Setting up @home structure.")?;

        let home_subvol = ctx.path("@home");
        let home_snapshots = home_subvol.join(".snapshots");

        // Create @home subvolume if needed
        if !home_subvol.exists() {
            ctx.log_info("Creating @home subvolume");
            SubvolumeHelper::create_subvolume(&home_subvol)?;
        }

        // Create @home/.snapshots subvolume
        if !home_snapshots.exists() {
            ctx.log_info("Creating @home/.snapshots subvolume");
            SubvolumeHelper::create_subvolume(&home_snapshots)?;

            // Set proper permissions for snapper
            ctx.log_info("Setting permissions for .snapshots directory");
            Command::new("chmod")
                .arg("755")
                .arg(&home_snapshots)
                .status()
                .map_err(|e| MigrationError::new(format!("Failed to set permissions: {}", e), "Permissions setup"))?;
        }

        // Migrate home data
        HomeDataMigrator::migrate(ctx)?;

        ctx.log_success("RootFSv3 migration completed");
        Ok(())
    }

    fn show_plymouth_message(message: &str) -> MigrationResult<()> {
        Command::new("plymouth")
            .arg("display-message")
            .arg(format!("--text={}", message))
            .status()
            .map(|_| ())
            .map_err(|e| MigrationError::new(format!("Failed to show plymouth message: {}", e), "UI").into())
    }
}

struct RootFsV2Migrator;

impl RootFsV2Migrator {
    fn migrate(ctx: &mut MigrationContext) -> MigrationResult<bool> {
        let system_path = ctx.path("@system");

        if system_path.exists() {
            ctx.log_info("@system exists, skipping RootFSv2 migration");
            return Ok(false);
        }

        ctx.log_step("Starting RootFSv2 migration");

        // Wait for devices to settle down a bit, otherwise we risk breaking plymouth and printing into the void, leaving
        // the user without any indication what is going on.
        // We do this relatively late in the transition progress so it doesn't unnecessarily delay regular boots.
        ctx.log_info("Waiting for devices to settle...");
        Command::new("udevadm")
            .arg("settle")
            .arg("--timeout=8")
            .status()
            .map_err(|e| MigrationError::new(format!("Failed to settle devices: {}", e), "V2 migration"))?;

        Self::show_plymouth_message("Migrating to v2 rootfs. This may take a while.")?;

        let import_path = ctx.path("@system.import");
        Self::prepare_import_directory(ctx, &import_path)?;
        Self::handle_fstab_warnings(ctx)?;

        let rootfs_v1 = LegacyRootFsV1Finder::find_latest(&ctx.root_path)?
            .ok_or_else(|| MigrationError::new("No legacy rootfs v1 found", "V2 migration"))?;

        Self::migrate_system_directories(ctx, &rootfs_v1, &import_path)?;
        Self::migrate_subvolumes(ctx, &import_path)?;
        Self::finalize_migration(ctx, &import_path, &system_path)?;

        ctx.log_success("RootFSv2 migration completed");
        Ok(true)
    }

    fn prepare_import_directory(ctx: &MigrationContext, import_path: &Path) -> MigrationResult<()> {
        // Clean up existing import directory
        if import_path.exists() {
            ctx.log_info("Cleaning up existing @system.import");
            SubvolumeHelper::delete_subvolume(import_path)
                .map_err(|e| MigrationError::new(format!("Failed to remove existing import: {}", e), "V2 preparation"))?;
        }

        ctx.log_info("Creating @system.import subvolume");
        SubvolumeHelper::create_subvolume(import_path)?;

        Ok(())
    }

    fn handle_fstab_warnings(ctx: &MigrationContext) -> MigrationResult<()> {
        // May or may not exist. Don't trip over it!
        let fstab_path = ctx.path("@etc-overlay/upper/fstab");
        let fstab = FsTab::new(&fstab_path);

        let mut concerning_fstab_entries = 0;
        for entry in fstab.get_entries().unwrap_or_default() {
            if entry.vfs_type != "swap" {
                concerning_fstab_entries += 1;
            }
        }

        if concerning_fstab_entries > 0 {
            ctx.log_warning(&format!("Found {} concerning fstab entries", concerning_fstab_entries));
            Self::show_fstab_warning(ctx, concerning_fstab_entries)?;
        }

        Ok(())
    }

    fn show_fstab_warning(ctx: &MigrationContext, count: usize) -> MigrationResult<()> {
        Command::new("plymouth").arg("hide-splash").status().ok();

        ctx.log_info("Displaying QR code for migration instructions");
        let _ = qr2term::print_qr("https://community.kde.org/KDE_Linux/RootFSv2");

        println!(
            "Found {count} concerning fstab entries. This suggests you have a more complicated fstab setup that we cannot auto-migrate. \
            If nothing critically important is managed by fstab you can let the auto-migration run. If you have entries that are required for the system to boot you should manually migrate to @system."
        );
        io::stdout().flush().unwrap();

        let migrate = Confirm::with_theme(&ColorfulTheme::default())
            .with_prompt("Do you want to continue with auto-migration?")
            .interact()
            .unwrap();

        if !migrate {
            ctx.log_info("User chose to abort migration - rebooting");
            Command::new("systemctl")
                .arg("reboot")
                .status()
                .map_err(|e| MigrationError::new(format!("Failed to reboot: {}", e), "User abort"))?;
            return Err("Migration aborted by user".into());
        }

        Ok(())
    }

    fn migrate_system_directories(ctx: &MigrationContext, rootfs_v1: &Path, import_path: &Path) -> MigrationResult<()> {
        ctx.log_info("Migrating system directories");

        for dir in ["etc", "var"] {
            let compose_dir = rootfs_v1.join(dir);
            let overlay_mount = Self::mount_overlay(ctx, &compose_dir, dir)?;

            ctx.log_info(&format!("Copying {} directory", dir));
            Self::copy_directory_with_reflink(&compose_dir, &import_path.join(dir))?;

            drop(overlay_mount); // Explicitly unmount
        }

        Ok(())
    }

    fn mount_overlay<'a>(ctx: &MigrationContext, compose_dir: &'a Path, dir: &'a str) -> MigrationResult<impl Drop + 'a> {
        ctx.log_info(&format!("Mounting overlay for {}", dir));

        let lower_dir = compose_dir.to_string_lossy();

        // Fix for temporary value lifetime issues
        let upper_path = ctx.path(&format!("@{}-overlay/upper", dir));
        let work_path = ctx.path(&format!("@{}-overlay/work", dir));

        let upper_dir = upper_path.to_string_lossy();
        let work_dir = work_path.to_string_lossy();

        let options = format!(
            "ro,lowerdir={},upperdir={},workdir={},index=off,metacopy=off",
            lower_dir, upper_dir, work_dir
        );

        let status = Command::new("mount")
            .arg("--verbose")
            .arg("--types")
            .arg("overlay")
            .arg("--options")
            .arg(&options)
            .arg("overlay")
            .arg(compose_dir)
            .status()
            .map_err(|e| MigrationError::new(format!("Failed to mount overlay: {}", e), "Overlay mount"))?;

        if !status.success() {
            return Err(MigrationError::new("Overlay mount failed", "V2 migration").into());
        }

        // Use move to capture variables by value
        let compose_dir = compose_dir.to_path_buf();
        let dir = dir.to_string();
        Ok(scopeguard::guard((), move |_| {
            println!("    INFO: Unmounting overlay for {}", dir);
            Command::new("umount").arg(&compose_dir).status().ok();
        }))
    }

    fn copy_directory_with_reflink(src: &Path, dst: &Path) -> MigrationResult<()> {
        let status = Command::new("cp")
            .arg("--recursive")
            .arg("--archive")
            .arg("--reflink=auto")
            .arg("--no-target-directory")
            .arg(src)
            .arg(dst)
            .status()
            .map_err(|e| MigrationError::new(format!("Failed to copy directory: {}", e), "Directory copy"))?;

        if !status.success() {
            return Err(MigrationError::new("Directory copy failed", "V2 migration").into());
        }

        Ok(())
    }

    fn migrate_subvolumes(ctx: &MigrationContext, import_path: &Path) -> MigrationResult<()> {
        ctx.log_info("Migrating subvolumes");

        let subvol_targets = [
            ("@home", "home"),
            ("@root", "root"),
            ("@snap", "snap"),
            ("@containers", "var/lib/containers"),
            ("@docker", "var/lib/docker"),
        ];

        for (subvol, target) in &subvol_targets {
            ctx.log_info(&format!("Snapshotting {} to {}", subvol, target));
            Self::create_subvolume_snapshot(ctx, subvol, &import_path.join(target))?;
        }

        Ok(())
    }

    fn create_subvolume_snapshot(ctx: &MigrationContext, subvol: &str, target: &Path) -> MigrationResult<()> {
        let source_path = ctx.path(subvol);

        // Clean up existing target
        if target.exists() {
            ctx.log_info(&format!("Removing existing target: {:?}", target));
            fs::remove_dir_all(target)
                .map_err(|e| MigrationError::new(format!("Failed to remove target: {}", e), "Subvolume migration"))?;
        }

        // Create parent directory if needed
        if let Some(parent) = target.parent() {
            // Inside var the target_path may already exist if they predate the subvolumes. Originally containers and docker were not subvolumes.
            // Make sure to throw the data away before trying to snapshot, otherwise the snapshot will fail.
            if parent != Path::new("") && !parent.exists() {
                // bit crap but parent of a relative path is the empty path.
                ctx.log_info(&format!("Creating parent directory: {:?}", parent));
                fs::create_dir_all(parent)
                    .map_err(|e| MigrationError::new(format!("Failed to create parent directory: {}", e), "Subvolume migration"))?;
            }
        }

        SubvolumeHelper::create_snapshot(&source_path, target)?;
        Ok(())
    }

    fn finalize_migration(ctx: &MigrationContext, import_path: &Path, system_path: &Path) -> MigrationResult<()> {
        ctx.log_info("Finalizing migration");
        fs::rename(import_path, system_path)
            .map_err(|e| MigrationError::new(format!("Failed to rename import to system: {}", e), "V2 finalization"))?; // fatal problem
        Ok(())
    }

    fn show_plymouth_message(message: &str) -> MigrationResult<()> {
        Command::new("plymouth")
            .arg("display-message")
            .arg(format!("--text={}", message))
            .status()
            .map(|_| ())
            .map_err(|e| MigrationError::new(format!("Failed to show plymouth message: {}", e), "UI").into())
    }
}

fn run_migrations(root: &Path) -> MigrationResult<()> {
    let mut ctx = MigrationContext::new(root);

    println!("Checking for rootfs migrations...");

    // Run V2 migration if needed
    let v2_migrated = RootFsV2Migrator::migrate(&mut ctx)?;

    // Run V3 migration if needed
    if RootFsV3Checker::needs_migration(root)? {
        RootFsV3Migrator::migrate(&mut ctx)?;
    } else if !v2_migrated {
        ctx.log_info("System is already at RootFSv3 - no migrations needed");
    }

    Ok(())
}

fn main() -> MigrationResult<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Usage: {} <system_mount_point>", args[0]);
        println!("Migrates legacy subvolumes (pre-October-2025) to RootFSv3");
        return Err("Insufficient arguments".into());
    }

    let root = Path::new(&args[1]);
    println!("Starting migration process for: {:?}", root);

    match run_migrations(root) {
        Ok(()) => {
            println!("All migrations completed successfully.");
            Command::new("plymouth").arg("show-splash").status().ok();
            Ok(())
        }
        Err(e) => {
            eprintln!("Migration failed: {}", e);
            Command::new("plymouth").arg("quit").status().ok();
            Err(e)
        }
    }
}
