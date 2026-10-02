// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

use glob::glob;
use libbtrfsutil::{subvolume_info, sync, DeleteSubvolumeOptions};
use std::{env, fs, path::PathBuf};

fn find_subvolume(work_path: &PathBuf) -> PathBuf {
    let glob_path = work_path.join("kde-linux_*");
    let files = match glob(glob_path.to_str().expect("Invalid glob path")) {
        Ok(paths) => paths,
        Err(error) => panic!("Problem reading glob {glob_path:?}: {error:?}"),
    };
    for entry in files {
        match entry {
            Ok(path) => {
                if !path.is_dir() {
                    continue;
                }

                match subvolume_info(&path) {
                    Ok(_subvolume) => return path,
                    Err(_error) => continue,
                };
            }
            Err(error) => println!("Problem reading glob entry: {error:?}"),
        }
    };
    panic!("No subvolume found in {work_path:?}");
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Usage: {} <subvolume_path>", args[0]);
        println!("Cleans up all subvolumes in the given path. Recursively.");
        return;
    }

    let relative_work_path = PathBuf::from(&args[1]);
    let work_path = match fs::canonicalize(&relative_work_path) {
        Ok(path) => path,
        Err(error) => panic!("Problem resolving {relative_work_path:?}: {error:?}"),
    };

    let subvolume_path = find_subvolume(&work_path);
    // Make sure it's a subvolume
    match subvolume_info(&subvolume_path) {
        Ok(subvolume) => subvolume,
        Err(error) => panic!("Problem getting subvolume info: {error:?}"),
    };

    // Delete it recursively. This internally implements all the right logic to
    // delete the subvolume and all its children even inside a docker container where the paths are nonsense.
    match DeleteSubvolumeOptions::new().recursive(true).delete(&subvolume_path) {
        Ok(_) => println!("Deleted subvolume: {subvolume_path:?}"),
        Err(error) => println!("Problem deleting subvolume {subvolume_path:?}: {error:?}")
    }

    println!("Syncing {subvolume_path:?}…");
    let _ = sync(subvolume_path);
}
