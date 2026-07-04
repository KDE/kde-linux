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

func isChannelCommitMarker(key string) bool {
	base := filepath.Base(key)
	return base == "SHA256SUMS" || base == "SHA256SUMS.gpg"
}

func removeObject(ctx context.Context, client *minio.Client, bucket string, objectKey string) {
	log.Printf("Removing source object s3://%s/%s", bucket, objectKey)
	if err := client.RemoveObject(ctx, bucket, objectKey, minio.RemoveObjectOptions{}); err != nil {
		log.Fatalf("Failed to remove source object s3://%s/%s: %v", bucket, objectKey, err)
	}
}

// publish copies a source tree into its destination tree.
func publish(client *minio.Client, srcBucket string, srcPath string, destBucket string, destPath string) {
	ctx := context.Background()

	srcPrefix := prefix(srcPath)
	destPrefix := prefix(destPath)

	objects := client.ListObjects(ctx, srcBucket, minio.ListObjectsOptions{
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
			removeObject(ctx, client, srcBucket, objectKey)
			continue
		}
		destKey := destPrefix + rel
		if srcBucket == destBucket && destKey == objectKey {
			continue
		}

		log.Printf("Publishing s3://%s/%s -> s3://%s/%s", srcBucket, objectKey, destBucket, destKey)

		_, err := client.ComposeObject(ctx,
			minio.CopyDestOptions{Bucket: destBucket, Object: destKey},
			minio.CopySrcOptions{Bucket: srcBucket, Object: objectKey},
		)
		if err != nil {
			log.Fatalf(
				"Failed to copy s3://%s/%s to s3://%s/%s: %v",
				srcBucket, objectKey,
				destBucket, destKey,
				err,
			)
		}

		removeObject(ctx, client, srcBucket, objectKey)
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

func parseURL(URLString string) *url.URL {
	parsedURL, err := url.Parse(URLString)
	if err != nil {
		log.Fatalln("Failed to parse URL:", err)
	}
	if parsedURL.Scheme != "s3+https" {
		log.Fatalln("Unsupported URL scheme:", parsedURL.Scheme)
	}
	if parsedURL.Host != "storage.kde.org" {
		log.Fatalln("Unsupported URL host:", parsedURL.Host)
	}
	return parsedURL
}

func getBucketAndPath(bucketURL *url.URL) (string, string) {
	path := strings.Trim(bucketURL.Path, "/")
	if path == "" {
		log.Fatalln("Invalid URL path, expected at least /bucket")
	}

	parts := strings.SplitN(path, "/", 2)
	bucket := parts[0]
	if bucket == "" {
		log.Fatalln("Invalid URL path, expected at least /bucket")
	}

	objectPrefix := ""
	if len(parts) == 2 {
		objectPrefix = strings.Trim(parts[1], "/")
	}

	return bucket, objectPrefix
}

// Either downloads every build artifact from the source into --output,
// or publishes the source tree into the destination.
func main() {
	src := flag.String("src", "", "source URL to publish from, e.g. s3+https://storage.kde.org/ci-artifacts/project/j/1")
	downloadMode := flag.Bool("download", false, "download artifacts from the source tree")
	output := flag.String("output", ".", "directory to download artifacts into")
	dest := flag.String("dest", "", "destination URL to publish to, e.g. s3+https://storage.kde.org/kde-linux/")
	flag.Parse()

	if *downloadMode == (*dest != "") {
		log.Fatalln("Must choose exactly one of --download or --dest")
	}

	srcURL := parseURL(*src)
	srcBucket, srcPath := getBucketAndPath(srcURL)

	if *downloadMode {
		log.Println("Connecting to MinIO at", srcURL.Host)
		minioClient := connectToMinIO(srcURL.Host)
		log.Println("Downloading artifacts from source bucket", srcBucket, "with path prefix", srcPath, "into", *output)
		download(minioClient, srcBucket, srcPath, *output)
	}

	if *dest != "" {
		if srcPath == "" {
			log.Fatalln("Source URL path must include a non-empty object prefix when publishing")
		}

		destURL := parseURL(*dest)
		destBucket, destPath := getBucketAndPath(destURL)

		if srcURL.Host != destURL.Host {
			log.Fatalln("Source and destination endpoints must be the same.")
		}

		log.Println("Connecting to MinIO at", srcURL.Host)
		minioClient := connectToMinIO(srcURL.Host)

		log.Println("Publishing from source bucket", srcBucket, "with path prefix", srcPath, "to destination bucket", destBucket, "with path prefix", destPath)
		publish(minioClient, srcBucket, srcPath, destBucket, destPath)
	}
}
