// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2025 Hadi Chokr hadichokr@icloud.com

package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// lineRegex matches tmpfiles.d symlink lines (L, L?, L+)
// capturing the path and the remaining fields (placeholders + target)
var (
	lineRegex = regexp.MustCompile(`^L[\?\+]*\s+([^\s]+)\s+[^\s]*\s+[^\s]*\s+[^\s]*\s+(.*)$`)

	// ANSI color codes for human-readable terminal output
	colorReset   = "\033[0m"
	colorGreen   = "\033[32m"
	colorYellow  = "\033[33m"
	colorRed     = "\033[31m"
	colorBoldRed = "\033[1;31m"
)

// cleanQuotes removes surrounding quotes and whitespace from a string
func cleanQuotes(s string) string {
	s = strings.TrimSpace(s)
	s = strings.Trim(s, `"`)
	s = strings.Trim(s, `'`)
	return s
}

// resolveTargetPath resolves a target path relative to the symlink's directory
func resolveTargetPath(symlinkPath, target string) string {
	// If target is already absolute, return as-is
	if filepath.IsAbs(target) {
		return target
	}
	
	// Resolve relative to the symlink's directory
	symlinkDir := filepath.Dir(symlinkPath)
	return filepath.Clean(filepath.Join(symlinkDir, target))
}

// factoryTarget returns the "factory default" target for a given path.
// /etc and /var have special handling; others are under /usr/share/factory.
func factoryTarget(path string) string {
	filename := filepath.Base(path)
	if filename == "etc" || strings.HasPrefix(path, "/etc/") {
		return "/usr/share/factory/etc/" + strings.TrimPrefix(path, "/etc/")
	} else if filename == "var" || strings.HasPrefix(path, "/var/") {
		return "/usr/share/factory/var/" + strings.TrimPrefix(path, "/var/")
	}
	return "/usr/share/factory" + path
}

// processLine handles L, L?, and L+ symlinks
// - L  : normal, errors if target missing
// - L? : optional, warns if target missing
// - L+ : force recreate, logs note about recreation
func processLine(line string, linkedDirs map[string]map[string]bool) error {
	if !strings.HasPrefix(line, "L") {
		return nil // Not a symlink line; skip
	}

	// Determine prefix: normal, optional, or force recreate
	prefix := line[:1]
	if len(line) > 1 && (line[1] == '?' || line[1] == '+') {
		prefix = line[:2]
	}
	
	targetOptional := false
	recreate := false

	switch prefix {
	case "L?":
		targetOptional = true
	case "L+":
		recreate = true
	}

	// Parse line using regex
	matches := lineRegex.FindStringSubmatch(line)
	if matches == nil {
		return nil // Line doesn't match expected L line format; skip
	}

	path := matches[1]

	// Extract the actual target: last field after placeholders
	targetField := matches[2]
	fields := strings.Fields(targetField)
	var target string
	if len(fields) > 0 {
		target = cleanQuotes(fields[len(fields)-1])
	} else {
		target = ""
	}

	// Handle factory default if target is empty or "-"
	if target == "" || target == "-" {
		ft := factoryTarget(path)
		fmt.Printf("%s -> (factory default: %s)\n", path, ft)
		if _, err := os.Stat(ft); err == nil {
			fmt.Printf("  %s✓ Factory target exists: %s%s\n", colorGreen, ft, colorReset)
		} else if targetOptional {
			fmt.Printf("  %s⚠ Factory target missing (optional): %s%s\n", colorYellow, ft, colorReset)
		} else {
			fmt.Printf("  %s✗ Factory target missing: %s%s\n", colorRed, ft, colorReset)
			return fmt.Errorf("missing factory target: %s", ft)
		}
		dir := filepath.Dir(ft)
		if !isBaseDir(dir) {
			if _, ok := linkedDirs[dir]; !ok {
				linkedDirs[dir] = make(map[string]bool)
			}
			linkedDirs[dir][filepath.Base(ft)] = true
		}
	} else {
		// Explicit target given - resolve relative path if needed
		resolvedTarget := resolveTargetPath(path, target)
		fmt.Printf("%s -> %s\n", path, target)
		if resolvedTarget != target {
			fmt.Printf("  %sResolved target: %s%s\n", colorYellow, resolvedTarget, colorReset)
		}
		
		if _, err := os.Stat(resolvedTarget); err == nil {
			fmt.Printf("  %s✓ Target exists: %s%s\n", colorGreen, resolvedTarget, colorReset)
			dir := filepath.Dir(resolvedTarget)
			if !isBaseDir(dir) {
				if _, ok := linkedDirs[dir]; !ok {
					linkedDirs[dir] = make(map[string]bool)
				}
				linkedDirs[dir][filepath.Base(resolvedTarget)] = true
			}
		} else if targetOptional {
			fmt.Printf("  %s⚠ Target missing (optional): %s%s\n", colorYellow, resolvedTarget, colorReset)
		} else {
			fmt.Printf("  %s✗ Target missing: %s%s\n", colorRed, resolvedTarget, colorReset)
			return fmt.Errorf("missing target: %s", resolvedTarget)
		}
	}

	if recreate {
		fmt.Printf("  %sNote: will recreate symlink if missing%s\n", colorYellow, colorReset)
	}

	return nil
}

// isBaseDir returns true if a directory is considered a base system dir
func isBaseDir(dir string) bool {
	baseDirs := []string{"/etc", "/var", "/usr", "/bin", "/sbin", "/lib", "/lib64", "/proc", "/run"}
	for _, b := range baseDirs {
		if dir == b {
			return true
		}
	}
	return false
}

// loadIgnoreFiles reads all .ignore files under /usr/share/tmpfiles.d/
func loadIgnoreFiles() map[string]bool {
	ignoredFiles := make(map[string]bool)
	files, _ := filepath.Glob("/usr/share/tmpfiles.d/*.ignore")

	for _, file := range files {
		f, err := os.Open(file)
		if err != nil {
			continue
		}
		scanner := bufio.NewScanner(f)
		for scanner.Scan() {
			line := strings.TrimSpace(scanner.Text())
			if line == "" || strings.HasPrefix(line, "#") {
				continue
			}
			ignoredFiles[line] = true
			fmt.Printf("   %s⤷ Ignore rule: skip %s (from %s)%s\n", colorYellow, line, file, colorReset)
		}
		f.Close()
	}
	return ignoredFiles
}

// checkDirectoryCompleteness ensures all files in tracked directories are either linked or ignored
func checkDirectoryCompleteness(linkedDirs map[string]map[string]bool, ignoredFiles map[string]bool) error {
	hadError := false
	for dir, linkedFiles := range linkedDirs {
		// Skip checking certain directories that aren't meant to be fully linked
		if strings.Contains(dir, "/.git") || dir == "." || dir == ".." {
			continue
		}
		
		entries, err := os.ReadDir(dir)
		if err != nil {
			continue
		}

		missing := []string{}
		for _, entry := range entries {
			if entry.IsDir() {
				continue
			}
			fullPath := filepath.Join(dir, entry.Name())
			if ignoredFiles[fullPath] {
				continue
			}
			if !linkedFiles[entry.Name()] {
				missing = append(missing, entry.Name())
			}
		}

		if len(missing) > 0 {
			fmt.Printf("%s✗ Error: Directory %s has symlinks in tmpfiles.d but not all files are linked.%s\n", colorRed, dir, colorReset)
			fmt.Printf("   Missing files: %s%s%s\n", colorRed, strings.Join(missing, ", "), colorReset)
			hadError = true
		}
	}
	if hadError {
		return fmt.Errorf("incomplete directory linking detected")
	}
	return nil
}

// printSummary outputs a detailed human-readable report
func printSummary(linkedDirs map[string]map[string]bool, ignoredFiles map[string]bool) {
	fmt.Println("\n=== Summary of Linked/Ignored/Missing Files ===")
	for dir, linkedFiles := range linkedDirs {
		// Skip certain directories in summary
		if strings.Contains(dir, "/.git") || dir == "." || dir == ".." {
			continue
		}
		
		entries, err := os.ReadDir(dir)
		if err != nil {
			fmt.Printf("%sDirectory: %s (cannot read: %v)%s\n", colorRed, dir, err, colorReset)
			continue
		}

		missing := []string{}
		ignored := []string{}
		actualLinked := []string{}

		for _, entry := range entries {
			if entry.IsDir() {
				continue
			}
			fullPath := filepath.Join(dir, entry.Name())
			if ignoredFiles[fullPath] {
				ignored = append(ignored, entry.Name())
			} else if linkedFiles[entry.Name()] {
				actualLinked = append(actualLinked, entry.Name())
			} else {
				missing = append(missing, entry.Name())
			}
		}

		if len(missing) > 0 {
			fmt.Printf("\n%sDirectory: %s%s\n", colorBoldRed, dir, colorReset)
		} else {
			fmt.Printf("\nDirectory: %s\n", dir)
		}

		if len(actualLinked) > 0 {
			fmt.Printf("  Linked files: %s%s%s\n", colorGreen, strings.Join(actualLinked, ", "), colorReset)
		}
		if len(ignored) > 0 {
			fmt.Printf("  Ignored files: %s%s%s\n", colorYellow, strings.Join(ignored, ", "), colorReset)
		}
		if len(missing) > 0 {
			fmt.Printf("  Missing files: %s%s%s\n", colorRed, strings.Join(missing, ", "), colorReset)
		} else {
			fmt.Println("  All files properly linked or ignored. 🎉 No broken links, unlike my love life!")
		}
	}
}

func main() {
	files, err := filepath.Glob("/usr/lib/tmpfiles.d/*.conf")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error finding files: %v\n", err)
		os.Exit(1)
	}

	exitCode := 0
	linkedDirs := make(map[string]map[string]bool)

	for _, file := range files {
		f, err := os.Open(file)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error opening file %s: %v\n", file, err)
			exitCode = 1
			continue
		}
		scanner := bufio.NewScanner(f)
		for scanner.Scan() {
			line := scanner.Text()
			// Skip comments and empty lines
			line = strings.TrimSpace(line)
			if line == "" || strings.HasPrefix(line, "#") {
				continue
			}
			// Only handle symlink lines (L, L?, L+)
			if strings.HasPrefix(line, "L") {
				if err := processLine(line, linkedDirs); err != nil {
					exitCode = 1
				}
			}
		}
		f.Close()
	}

	ignoredFiles := loadIgnoreFiles()

	if err := checkDirectoryCompleteness(linkedDirs, ignoredFiles); err != nil {
		exitCode = 1
	}

	printSummary(linkedDirs, ignoredFiles)
	os.Exit(exitCode)
}
