// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2024-2025 Harald Sitter <sitter@kde.org>
// SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

package main

import (
	"context"
	"flag"
	"log"
	"net/url"
	"path/filepath"
	"sort"
	"strings"

	"invent.kde.org/kde-linux/kde-linux/minioauth"

	"github.com/minio/minio-go/v7"
)

func connectToMinIO(endpoint string) *minio.Client {
	minioClient, err := minioauth.Connect(endpoint)
	if err != nil {
		log.Fatalln("Failed to connect to MinIO:", err)
	}

	buckets, err := minioauth.ListBuckets(minioClient)
	if err != nil {
		log.Fatalln("Failed to list buckets:", err)
	}
	for _, bucket := range buckets {
		log.Println(bucket)
	}

	return minioClient
}

func prefix(path string) string {
	trimmed := strings.Trim(path, "/")
	if trimmed == "" {
		return ""
	}
	return trimmed + "/"
}

func destinationPrefix(path string) string {
	path = strings.Trim(path, "/")
	if path == "" {
		log.Fatalln("Remote path must be a non-empty staging path")
	}

	parts := strings.Split(path, "/")
	for i, part := range parts {
		if part != "staging" {
			continue
		}
		if i == len(parts)-1 {
			log.Fatalln("Remote path must include a staging directory name")
		}
		if i == 0 {
			return ""
		}
		return strings.Join(parts[:i], "/") + "/"
	}

	log.Fatalln("Remote path must contain a staging directory")
	return ""
}

func isChannelCommitMarker(key string) bool {
	base := filepath.Base(key)
	return base == "SHA256SUMS" || base == "SHA256SUMS.gpg"
}

func removeObject(ctx context.Context, client *minio.Client, bucket string, objectKey string) {
	log.Printf("Removing staged object %s", objectKey)
	if err := client.RemoveObject(ctx, bucket, objectKey, minio.RemoveObjectOptions{}); err != nil {
		log.Fatalf("Failed to remove %s: %v", objectKey, err)
	}
}

// publish merges a staging tree into its channel root.
func publish(client *minio.Client, bucket string, path string) {
	ctx := context.Background()
	srcPrefix := prefix(path)

	destPrefix := destinationPrefix(path)

	objects := client.ListObjects(ctx, bucket, minio.ListObjectsOptions{
		Prefix:    srcPrefix,
		Recursive: true,
	})

	var objectKeys []string
	for object := range objects {
		if object.Err != nil {
			log.Fatalln("Failed to list objects:", object.Err)
		}
		objectKeys = append(objectKeys, object.Key)
	}
	sort.Strings(objectKeys)

	for _, objectKey := range objectKeys {
		rel := strings.TrimPrefix(objectKey, srcPrefix)
		if rel == "" {
			continue
		}
		if isChannelCommitMarker(rel) {
			log.Printf("Skipping staged commit marker %s", objectKey)
			removeObject(ctx, client, bucket, objectKey)
			continue
		}
		dstKey := destPrefix + rel
		if dstKey == objectKey {
			continue
		}

		log.Printf("Publishing %s -> %s", objectKey, dstKey)

		_, err := client.ComposeObject(ctx,
			minio.CopyDestOptions{Bucket: bucket, Object: dstKey},
			minio.CopySrcOptions{Bucket: bucket, Object: objectKey},
		)
		if err != nil {
			log.Fatalf("Failed to copy %s to %s: %v", objectKey, dstKey, err)
		}

		removeObject(ctx, client, bucket, objectKey)
	}
}

// artifactSuffixes are the build artifacts we download so they can be pushed to
// files.kde.org and the chunk store. sha256sums are regenerated at publish time, so they're excluded here
var artifactSuffixes = []string{".iso", ".torrent", ".efi", ".tar.zst", ".erofs", ".caibx"}

func isArtifact(key string) bool {
	for _, suffix := range artifactSuffixes {
		if strings.HasSuffix(key, suffix) {
			return true
		}
	}
	return false
}

// download gets every build artifact under path to publish to files.kde.org and the chunk store
func download(client *minio.Client, bucket string, path string, output string) {
	ctx := context.Background()

	objects := client.ListObjects(ctx, bucket, minio.ListObjectsOptions{
		Prefix:    prefix(path),
		Recursive: true,
	})

	for object := range objects {
		if object.Err != nil {
			log.Fatalln("Failed to list objects:", object.Err)
		}

		if !isArtifact(object.Key) {
			continue
		}

		dst := filepath.Join(output, filepath.Base(object.Key))
		log.Printf("Downloading %s -> %s", object.Key, dst)
		if err := client.FGetObject(ctx, bucket, object.Key, dst, minio.GetObjectOptions{}); err != nil {
			log.Fatalf("Failed to download %s: %v", object.Key, err)
		}
	}
}

// Either downloads every build artifact in the staging directory into --output,
// or promotes the staging tree into the channel root.
func main() {
	remote := flag.String("remote", "", "remote url to publish from, e.g. s3+https://storage.kde.org/kde-linux/staging/1")
	output := flag.String("output", ".", "directory to download artifacts into")
	downloadMode := flag.Bool("download", false, "download artifacts from the staging tree")
	promoteMode := flag.Bool("promote", false, "promote the staging tree into the channel root")
	flag.Parse()

	if *downloadMode == *promoteMode {
		log.Fatalln("Must choose exactly one of --download or --promote")
	}

	remoteURI, err := url.Parse(*remote)
	if err != nil {
		log.Fatalln("Failed to parse remote URL:", err)
	}
	if remoteURI.Scheme != "s3+https" {
		log.Fatalln("Unsupported remote scheme:", remoteURI.Scheme)
	}
	if remoteURI.Host != "storage.kde.org" {
		log.Fatalln("Unsupported remote host:", remoteURI.Host)
	}
	parts := strings.SplitN(remoteURI.Path[1:], "/", 2)
	if len(parts) != 2 {
		log.Fatalln("Invalid remote path, expected format: /bucket/path")
	}
	bucket := parts[0]
	path := parts[1]
	if bucket == "" {
		log.Fatalln("Invalid remote path, expected format: /bucket/path")
	}
	if path == "" {
		log.Println("Warning: path is empty, uploading to bucket root")
		path = "/"
	}

	log.Println("Connecting to MinIO at", remoteURI.Host)
	minioClient := connectToMinIO(remoteURI.Host)

	if *downloadMode {
		log.Println("Downloading artifacts from bucket", bucket, "with path prefix", path, "into", *output)
		download(minioClient, bucket, path, *output)
	}

	if *promoteMode {
		log.Println("Publishing to bucket", bucket, "from source path", path)
		publish(minioClient, bucket, path)
	}
}
