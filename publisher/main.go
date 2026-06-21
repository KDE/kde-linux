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
	"strings"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

func connectToMinIO(endpoint string) *minio.Client {
	awsSection, err := readConfigAWS("default")
	if err != nil {
		log.Fatalln("Failed to read AWS config:", err)
	}
	accessKeyID := awsSection.AccessKeyId
	if accessKeyID == "" {
		log.Fatalln("AWS access key ID is empty")
	}
	secretAccessKey := awsSection.SecretKey
	if secretAccessKey == "" {
		log.Fatalln("AWS secret access key is empty")
	}
	sessionToken := awsSection.SessionToken
	if secretAccessKey == "" {
		log.Fatalln("AWS session token is empty")
	}
	useSSL := true

	// Initialize minio client object.
	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:           credentials.NewStaticV4(accessKeyID, secretAccessKey, sessionToken),
		Secure:          useSSL,
		TrailingHeaders: true,
	})
	if err != nil {
		log.Fatalln("Failed to create MinIO client:", err)
	}

	buckets, err := minioClient.ListBuckets(context.Background())
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

// publish merges a staging tree into its channel root.
func publish(client *minio.Client, bucket string, path string) {
	ctx := context.Background()
	srcPrefix := prefix(path)

	destPrefix, _, _ := strings.Cut(path, "staging/")

	objects := client.ListObjects(ctx, bucket, minio.ListObjectsOptions{
		Prefix:    srcPrefix,
		Recursive: true,
	})

	for object := range objects {
		if object.Err != nil {
			log.Fatalln("Failed to list objects:", object.Err)
		}

		rel := strings.TrimPrefix(object.Key, srcPrefix)
		if rel == "" {
			continue
		}
		dstKey := destPrefix + rel
		if dstKey == object.Key {
			continue
		}

		log.Printf("Publishing %s -> %s", object.Key, dstKey)

		_, err := client.ComposeObject(ctx,
			minio.CopyDestOptions{Bucket: bucket, Object: dstKey},
			minio.CopySrcOptions{Bucket: bucket, Object: object.Key},
		)
		if err != nil {
			log.Fatalf("Failed to copy %s to %s: %v", object.Key, dstKey, err)
		}

		if err := client.RemoveObject(ctx, bucket, object.Key, minio.RemoveObjectOptions{}); err != nil {
			log.Fatalf("Failed to remove %s: %v", object.Key, err)
		}
	}
}

// download fetches every .caibx and .erofs object under path into the current
// working directory, so they can be fed into the chunk store.
func download(client *minio.Client, bucket string, path string) {
	ctx := context.Background()

	objects := client.ListObjects(ctx, bucket, minio.ListObjectsOptions{
		Prefix:    prefix(path),
		Recursive: true,
	})

	for object := range objects {
		if object.Err != nil {
			log.Fatalln("Failed to list objects:", object.Err)
		}

		if !strings.HasSuffix(object.Key, ".caibx") && !strings.HasSuffix(object.Key, ".erofs") {
			continue
		}

		dst := filepath.Base(object.Key)
		log.Printf("Downloading %s -> %s", object.Key, dst)
		if err := client.FGetObject(ctx, bucket, object.Key, dst, minio.GetObjectOptions{}); err != nil {
			log.Fatalf("Failed to download %s: %v", object.Key, err)
		}
	}
}

// Does two things:
// - publishes the image for public consumption
// - downloads .caibx and .erofs in the staging directory to the current dir, so it can be put into the chunk store
func main() {
	remote 	:= flag.String("remote", "", "remote url to publish from, e.g. s3+https://storage.kde.org/kde-linux/staging/1")
	flag.Parse()

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

	log.Println("Downloading .caibx and .erofs from bucket", bucket, "with path prefix", path)
	download(minioClient, bucket, path)

	log.Println("Publishing to bucket", bucket, "from source path", path)
	publish(minioClient, bucket, path)
}
