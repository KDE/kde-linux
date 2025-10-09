// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2024-2025 Harald Sitter <sitter@kde.org>

package main

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"sort"
	"strconv"
	"strings"

	"gopkg.in/yaml.v2"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

func connectToMinIO() *minio.Client {
	endpoint := "storage.kde.org"
	accessKeyID := "RFKVOIVSL4E307CSBN2W"
	secretAccessKey := "QtK7u0pq+C4ERdLsr1+HDbBShaAkeT1iNq+ZJQq5"
	useSSL := true

	// Initialize minio client object.
	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:           credentials.NewStaticV4(accessKeyID, secretAccessKey, ""),
		Secure:          useSSL,
		TrailingHeaders: true,
	})
	if err != nil {
		log.Fatalln(err)
	}

	buckets, err := minioClient.ListBuckets(context.Background())
	if err != nil {
		log.Fatalln(err)
	}
	for _, bucket := range buckets {
		log.Println(bucket)
	}

	return minioClient
}

func sha256File(path string) string {
	file, err := os.Open(path)
	if err != nil {
		log.Fatalf("unable to open file %s: %v", path, err)
	}
	defer file.Close()

	hasher := sha256.New()
	if _, err := io.Copy(hasher, file); err != nil {
		log.Fatalf("unable to hash file %s: %v", path, err)
	}
	return hex.EncodeToString(hasher.Sum(nil))
}

func loadReleasesMinIO(client *minio.Client, dir string, config *config) (releases map[string]release, err error) {
	releases = make(map[string]release)
	bucketName := "kde-linux"
	ctx := context.Background()

	log.Println("Loading releases from MinIO bucket", bucketName)

	objects := client.ListObjects(ctx, bucketName, minio.ListObjectsOptions{
		Prefix:       dir,
		Recursive:    false,
		WithMetadata: true,
	})
	for object := range objects {
		if object.Err != nil {
			log.Fatalln(object.Err)
		}

		log.Println("HALLO", object.Key, object.UserMetadata, object.ChecksumSHA256, "--", object.UserMetadata["X-Amz-Meta-X-Kde-Sha256"])

		err = appendRelease(&releases, S3Artifact{
			client:    client,
			bucket:    bucketName,
			path:      object.Key,
			sha256Sum: object.UserMetadata["X-Amz-Meta-X-Kde-Sha256"],
		})
		if err != nil {
			return
		}
	}

	log.Println(releases)
	return
}

func downloadCaibxFiles(client *minio.Client) (caibxFiles []string, err error) {
	bucketName := "kde-linux"
	ctx := context.Background()

	log.Println("Downloading caibx files from", bucketName)

	os.RemoveAll("caibx-files")
	objects := client.ListObjects(ctx, bucketName, minio.ListObjectsOptions{
		Recursive: true,
	})
	for object := range objects {
		if object.Err != nil {
			log.Fatalln(object.Err)
		}

		if !strings.HasSuffix(object.Key, ".caibx") {
			continue
		}

		log.Println("Downloading caibx", object.Key)
		path := filepath.Join("caibx-files", object.Key)
		err := client.FGetObject(ctx, bucketName, object.Key, path, minio.GetObjectOptions{})
		if err != nil {
			log.Fatalln(errors.New("Failed to download caibx " + object.Key + ": " + err.Error()))
		}
		caibxFiles = append(caibxFiles, path)
	}

	return
}

func readSHA256s(toKeep []string, releases map[string]release, existingSums map[string]string) []string {
	sha256s := []string{}
	for _, key := range toKeep {
		artifacts := releases[key].artifacts
		sort.Strings(artifacts) // Sort artifacts to ensure consistent order
		for _, artifact := range artifacts {
			if strings.HasSuffix(artifact, ".erofs.caibx") {
				// Keep .erofs.caibx out of the sha256sum file. They mess with match patterns.
				// https://github.com/systemd/systemd/issues/38605
				continue
			}
			if strings.HasPrefix(artifact, "/home/kdeos/kde-linux/kdeos_") {
				// HACK 2025-08-20 sha256s of the files are broken, only drop this if when they are fixed (possibly just a matter of time)
				continue
			}

			if sha256, ok := existingSums[artifact]; ok {
				// If we already have a SHA256 for this artifact, use it
				log.Println("Using existing SHA256 for", artifact)
				sha256s = append(sha256s, sha256)
				continue
			}

			sha256 := readSHA256(artifact + ".sha256")
			if sha256 == "" {
				log.Println("Failed to read SHA256 for", artifact)
				os.Exit(1)
			}
			sha256s = append(sha256s, sha256)
		}
	}
	return sha256s
}

func writeSHA256s(path string, sha256s []string) {
	file, err := os.Create(path)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	for _, sha256 := range sha256s {
		_, err := file.WriteString(sha256 + "\n")
		if err != nil {
			log.Fatal(err)
		}
	}
}

type config struct {
	TombstoneImages []string `yaml:"tombstone_images"`
	GoldenImages    []string `yaml:"golden_images"`
}

func readConfig(client *minio.Client) (*config, error) {
	configFile, err := client.GetObject(context.Background(), "kde-linux", "vacuum.yaml", minio.GetObjectOptions{})
	if err != nil {
		return nil, err
	}
	defer configFile.Close()

	data, err := io.ReadAll(configFile)
	if err != nil {
		return nil, err
	}

	var config config
	err = yaml.UnmarshalStrict(data, &config)
	if err != nil {
		return nil, err
	}

	return &config, nil
}

func getReleaseFrom(name string) (string, error) {
	name = strings.TrimPrefix(name, "kdeos_")
	name = strings.TrimPrefix(name, "kde-linux_")
	name = strings.SplitN(name, ".", 2)[0]
	name = strings.SplitN(name, "_", 2)[0]

	_, err := strconv.Atoi(name)
	if err != nil {
		return "", errors.New("Failed to parse release number: " + name)
	}
	return name, nil
}

func appendRelease(releases *map[string]release, artifact Artifact) error {
	// NOTE: we want to keep the legacy kdeos_ prefix for as long as we have relevant tombstones around. Which is possibly forever.
	basename := filepath.Base(artifact.Path())
	if !strings.HasPrefix(basename, "kdeos_") && !strings.HasPrefix(basename, "kde-linux_") {
		return nil
	}

	name, err := getReleaseFrom(basename)
	if err != nil {
		return err
	}

	if _, ok := (*releases)[name]; !ok {
		(*releases)[name] = release{}
	}
	release := (*releases)[name]
	release.artifacts = append(release.artifacts, artifact)
	(*releases)[name] = release
	return nil
}

func removeV3(client *minio.Client) {
	iter := client.ListObjectsIter(context.Background(), "kde-linux", minio.ListObjectsOptions{
		Prefix:    "",
		Recursive: true,
	})
	results, err := client.RemoveObjectsWithIter(context.Background(), "kde-linux", iter, minio.RemoveObjectsOptions{})
	if err != nil {
		log.Fatalln(err)
	}
	for result := range results {
		if result.Err != nil {
			log.Fatalln("Failed to remove", result.ObjectName, result.Err)
		}
	}
}

func uploadR(client *minio.Client) {
	err := filepath.WalkDir("r", func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		objectName, err := filepath.Rel("r/", path)
		if err != nil {
			return err
		}

		if d.IsDir() {
			return nil
		}

		log.Println("Uploading", objectName, "from", path)
		info, err := client.FPutObject(context.Background(), "kde-linux", objectName, path, minio.PutObjectOptions{
			UserMetadata: map[string]string{
				"X-KDE-SHA256": sha256File(path),
			},
		})
		if err != nil {
			log.Fatalln(err)
		}
		log.Println("Uploaded", objectName, "of size", info.Size, "ETag", info.ETag, "VersionID", info.VersionID, "SHA256", info.ChecksumSHA256, "Metadata", info)

		log.Println(path, d)
		return nil
	})
	if err != nil {
		log.Fatalln(err)
	}
}

func uploadVacuum(client *minio.Client) {
	_, err := client.FPutObject(context.Background(), "kde-linux", "vacuum.yaml", "r/vacuum.yaml", minio.PutObjectOptions{})
	if err != nil {
		log.Fatalln(err)
	}
}

func buildDeletionSlice(releases map[string]release, toProtect []string) (toKeep, toDelete []string) {
	if len(releases) == 0 {
		log.Println("No releases found")
		return
	}

	// Sort releases by key
	for key := range releases {
		toKeep = append(toKeep, key)
	}
	sort.Sort(sort.Reverse(sort.StringSlice(toKeep)))

	for len(toKeep) > 4 {
		release := toKeep[len(toKeep)-1]
		// Protect certain releases from deletion
		if !slices.Contains(toProtect, release) {
			log.Println("Marking for deletion (unless protected)", release)
			toDelete = append(toDelete, release)
		}
		toKeep = toKeep[:len(toKeep)-1]
	}
	// always keep protected version, only appending here for logging reasons. The actual protection is above!
	toKeep = append(toKeep, toProtect...)
	return
}

func deleteReleases(releases map[string]release, toKeep, toDelete []string) {
	for _, key := range toDelete {
		log.Println("Deleting", key)
		for _, artifact := range releases[key].artifacts {
			log.Println("Deleting", artifact.Path())
			if os.Getenv("VACUUM_REALLY_DELETE") == "1" {
				err := artifact.Delete()
				if err != nil {
					log.Println("Failed to delete", artifact, err)
				}
			} else {
				log.Println("... not really deleting")
			}
		}
	}

	for _, key := range toKeep {
		log.Println("Keeping", key)
	}
}

func generateSHA256s(releases map[string]release, toKeep []string, dir string) {
	sha256s := []string{}
	for _, key := range toKeep {
		for _, artifact := range releases[key].artifacts {
			sha256 := artifact.SHA256()
			if sha256 != "" {
				sha256s = append(sha256s)
			}
		}
	}

	sumsDir := filepath.Join("upload-tree", dir)
	os.MkdirAll(sumsDir, 0o700)
	writeSHA256s(filepath.Join(sumsDir, "SHA256SUMS"), sha256s)
}

func main() {
	minioClient := connectToMinIO()
	os.Chdir("../") // We get started inside the vacuum dir, move to the root.

	/////////////////////////////////////////
	removeV3(minioClient)
	uploadR(minioClient)
	/////////////////////////////////////////

	os.RemoveAll("upload-tree")

	config, err := readConfig(minioClient)
	if err != nil {
		log.Fatal(err)
	}

	var toProtect []string
	for _, release := range config.TombstoneImages {
		toProtect = append(toProtect, release)
	}
	for _, release := range config.GoldenImages {
		toProtect = append(toProtect, release)
	}

	// Clean up the sysupdate directories
	for _, dir := range []string{"testing/sysupdate/v2/", "testing/sysupdate/v3/"} {
		releases, err := loadReleasesMinIO(minioClient, dir, config)
		if err != nil {
			log.Fatal(err)
		}

		toKeep, toDelete := buildDeletionSlice(releases, toProtect)
		deleteReleases(releases, toKeep, toDelete)

		generateSHA256s(releases, toKeep, dir)
	}

	// Clean up the images
	{
		dir := "testing/"

		releases, err := loadReleasesMinIO(minioClient, dir, config)
		if err != nil {
			log.Fatal(err)
		}

		toKeep, toDelete := buildDeletionSlice(releases, toProtect)
		deleteReleases(releases, toKeep, toDelete)
	}

	// Clean up the desync store
	// TODO move this into its own thing, we only need to run this weekly or so, it is a bit expensive
	{
		caibxFiles, err := downloadCaibxFiles(minioClient)
		if err != nil {
			log.Fatal(err)
		}

		args := []string{"prune", "--yes", "--store", "s3+https://storage.kde.org/kde-linux/sysupdate/store"}
		args = append(args, caibxFiles...)
		cmd := exec.Command("desync", args...)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr

		err = cmd.Run()
		if err != nil {
			log.Fatal("desync prune failed: ", err)
		}

		log.Println("Ran", cmd.Args)
		if cmd.ProcessState.ExitCode() != 0 {
			log.Fatal("desync prune failed. This is a critical problem. Get someone on this immediately!")
		}
	}
}
