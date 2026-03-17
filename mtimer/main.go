// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

package main

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"flag"
	"io"
	"log"
	"log/slog"
	"os"
	"path/filepath"
	"runtime"
	"sort"
	"strings"
	"time"

	"golang.org/x/sync/errgroup"
)

type DirInfo struct {
	absPath string
	info    os.FileInfo
}

type FileInfo struct {
	SHA256 string `json:"sha256"`
	MTime  int64  `json:"mtime"`
}

type LinkInfo struct {
	Target string `json:"target"`
	MTime  int64  `json:"mtime"`
}

type SHA256Sums struct {
	Files    map[string]FileInfo `json:"files"`
	Symlinks map[string]LinkInfo `json:"symlinks"`
}

type FileAnalysis struct {
	statInfo os.FileInfo
	blobInfo FileInfo
	absPath  string
	relPath  string
}

type LinkAnalysis struct {
	statInfo os.FileInfo
	blobInfo LinkInfo
	absPath  string
	relPath  string
}

func loadBlob(jsonPath string) (*SHA256Sums, error) {
	data, err := os.ReadFile(jsonPath)
	if err != nil {
		return nil, err
	}

	var sums SHA256Sums
	err = json.Unmarshal(data, &sums)
	if err != nil {
		return nil, err
	}
	return &sums, nil
}

func sha256SumFile(path string) string {
	f, err := os.Open(path)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	h := sha256.New()
	if _, err := io.Copy(h, f); err != nil {
		log.Fatal(err)
	}
	return hex.EncodeToString(h.Sum(nil))
}

func recordNewFile(blob *SHA256Sums, absPath string, relPath string, info os.FileInfo) {
	blob.Files[relPath] = FileInfo{
		SHA256: sha256SumFile(absPath),
		MTime:  info.ModTime().Unix(),
	}
}

func recordNewSymlink(blob *SHA256Sums, absPath string, relPath string, info os.FileInfo) {
	target, err := os.Readlink(absPath)
	if err != nil {
		log.Fatal(err)
	}

	blob.Symlinks[relPath] = LinkInfo{
		Target: target,
		MTime:  info.ModTime().Unix(),
	}
}

func analyzeFile(input FileAnalysis) FileAnalysis {
	newSum := sha256SumFile(input.absPath)
	if input.blobInfo.SHA256 != newSum {
		// File is really different
		return FileAnalysis{
			blobInfo: FileInfo{
				SHA256: newSum,
				MTime:  input.statInfo.ModTime().Unix(),
			},
			absPath: input.absPath,
			relPath: input.relPath,
		}
	}

	// The file has not actually changed. Apply the original mtime.
	slog.Debug("Restoring mtime for file", "path", input.relPath)
	os.Chtimes(input.absPath, time.Unix(input.blobInfo.MTime, 0), time.Unix(input.blobInfo.MTime, 0))
	return input
}

func analyzeLink(input LinkAnalysis) LinkAnalysis {
	newTarget, err := os.Readlink(input.absPath)
	if err != nil {
		log.Fatal(err)
	}

	if input.blobInfo.Target != newTarget {
		// Link actually changed
		return LinkAnalysis{
			blobInfo: LinkInfo{
				Target: newTarget,
				MTime:  input.statInfo.ModTime().Unix(),
			},
			absPath: input.absPath,
			relPath: input.relPath,
		}
	}

	// The link has not actually changed. Apply the original mtime.
	slog.Debug("Restoring mtime for symlink", "path", input.relPath)
	os.Chtimes(input.absPath, time.Unix(input.blobInfo.MTime, 0), time.Unix(input.blobInfo.MTime, 0))
	return input
}

func updateDir(dir DirInfo) {
	entries, err := os.ReadDir(dir.absPath)
	if err != nil {
		log.Fatal(err)
	}

	latest := time.Unix(0, 0)
	for _, entry := range entries {
		if entry.Type()&os.ModeSymlink != 0 {
			continue
		}
		entryInfo, err := entry.Info()
		if err != nil {
			log.Fatal(err)
		}
		if entryInfo.ModTime().After(latest) {
			latest = entryInfo.ModTime()
		}
	}

	if err := os.Chtimes(dir.absPath, latest, latest); err != nil {
		log.Fatal(err)
	}
}

func main() {
	root := flag.String("root", "", "rootfs to operate on")
	jsonPath := flag.String("json", "", "json file to read and write")
	flag.Parse()

	if *root == "" {
		log.Fatal("no root path specified")
	}
	if *jsonPath == "" {
		log.Fatal("no json path specified")
	}

	blob, err := loadBlob(*jsonPath)
	if err != nil {
		log.Fatal(err)
	}

	newBlob := &SHA256Sums{
		Files:    map[string]FileInfo{},
		Symlinks: map[string]LinkInfo{},
	}

	// We also collect all directories so we might chmod them later.
	dirs := []DirInfo{}

	toAnalyze := []FileAnalysis{}
	linksToAnalyze := []LinkAnalysis{}
	err = filepath.Walk(*root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() {
			// We analyze dirs in a special pass later.
			dirs = append(dirs, DirInfo{absPath: path, info: info})
			return nil
		}

		relPath, err := filepath.Rel(*root, path)
		if err != nil {
			return err
		}

		if info.Mode()&os.ModeSymlink != 0 {
			blobInfo, ok := blob.Symlinks[relPath]
			if !ok {
				// New symlink, create new entry
				recordNewSymlink(newBlob, path, relPath, info)
				return nil
			}

			if blobInfo.MTime != info.ModTime().Unix() { // We only care about seconds precision, there is more than that between two builds anyway
				// Changed file, queue for analysis
				linksToAnalyze = append(linksToAnalyze, LinkAnalysis{
					statInfo: info,
					blobInfo: blobInfo,
					absPath:  path,
					relPath:  relPath,
				})
				return nil
			}

			// Unchanged, carry over old entry
			newBlob.Symlinks[relPath] = blobInfo
			return nil
		}

		blobInfo, ok := blob.Files[relPath]
		if !ok {
			// New file, create new entry
			recordNewFile(newBlob, path, relPath, info)
			return nil
		}

		if blobInfo.MTime != info.ModTime().Unix() { // We only care about seconds precision, there is more than that between two builds anyway
			// Changed file, queue for analysis
			toAnalyze = append(toAnalyze, FileAnalysis{
				statInfo: info,
				blobInfo: blobInfo,
				absPath:  path,
				relPath:  relPath,
			})
			return nil
		}

		// Unchanged, carry over old entry
		newBlob.Files[relPath] = blobInfo
		return nil
	})
	if err != nil {
		log.Fatal(err)
	}

	ctx := context.Background()
	g, ctx := errgroup.WithContext(ctx)
	g.SetLimit(runtime.NumCPU())

	fileResults := make([]FileAnalysis, len(toAnalyze))
	for i, input := range toAnalyze {
		i, input := i, input // https://golang.org/doc/faq#closures_and_goroutines
		g.Go(func() error {
			info := analyzeFile(input)
			fileResults[i] = info
			return nil
		})
	}

	linkResults := make([]LinkAnalysis, len(linksToAnalyze))
	for i, input := range linksToAnalyze {
		i, input := i, input // https://golang.org/doc/faq#closures_and_goroutines
		g.Go(func() error {
			info := analyzeLink(input)
			linkResults[i] = info
			return nil
		})
	}

	g.Go(func() error {
		// Sort directories by depth, deepest first.
		// Be mindful that we change dirs in-place. This is not thread safe and relies on our errgroup waiting!
		sort.Slice(dirs, func(i, j int) bool { return strings.Count(dirs[i].absPath, "/") > strings.Count(dirs[j].absPath, "/") })
		return nil
	})

	if err := g.Wait(); err != nil {
		log.Fatal(err)
	}

	for _, result := range fileResults {
		newBlob.Files[result.relPath] = result.blobInfo
	}

	for _, result := range linkResults {
		newBlob.Symlinks[result.relPath] = result.blobInfo
	}

	// Now let's chtimes the directories to the latest mtime of their contents.
	// This could be more efficient but makes for somewhat complicated code.
	// Instead we run the directories in a single thread.
	// Unfortunate but it is what it is.
	for _, dir := range dirs {
		updateDir(dir)
	}

	data, err := json.Marshal(newBlob)
	if err != nil {
		log.Fatal(err)
	}
	if err := os.WriteFile(*jsonPath, data, 0644); err != nil {
		log.Fatal(err)
	}
}
