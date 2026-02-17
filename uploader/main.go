// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2024-2025 Harald Sitter <sitter@kde.org>

package main

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"flag"
	"io"
	"log"
	"net/url"
	"os"
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

func upload(client *minio.Client, bucket string, objectNamePrefix string) {
	dir := "../upload-tree"
	err := filepath.WalkDir(dir, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		objectName, err := filepath.Rel(dir, path)
		if err != nil {
			return err
		}
		objectName = filepath.Join(objectNamePrefix, objectName)
		if objectName == "" {
			return errors.New("object name cannot be empty")
		}

		if d.IsDir() {
			return nil
		}

		log.Println("Uploading", objectName, "from", path)
		info, err := client.FPutObject(context.Background(), bucket, objectName, path, minio.PutObjectOptions{
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

func main() {
	remote := flag.String("remote", "", "remote url to upload to, e.g. s3+https://storage.kde.org/kde-linux/sysupdate/v2/store")
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

	log.Println("Uploading to bucket", bucket, "with path prefix", path)
	upload(minioClient, bucket, path)
}
