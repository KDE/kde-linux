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
	"sync"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/s3/transfermanager"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func connectToS3(endpoint string) *s3.Client {
	cfg, err := config.LoadDefaultConfig(
		context.TODO(),
		config.WithRegion("us-east-1"),
	)
	if err != nil {
		log.Fatalf("failed to load SDK configuration, %v", err)
	}

	client := s3.NewFromConfig(cfg, func(o *s3.Options) {
		o.BaseEndpoint = aws.String("https://s3.kde.org")
		o.UsePathStyle = true
	})
	return client
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

type UploadObject struct {
	ObjectName string
	Path       string
	SHA256     string
}

func upload(client *s3.Client, bucket string, objectNamePrefix string) {
	dir := "../upload-tree"

	// Somewhat involved producer-consumer going on here.
	// - We start N sha256 calculation workers.
	// - We then feed the calcs channel with partial UploadObjects.
	// - Close the calcs channel to eventually let the workers drain and finish.
	// - The workers calculate the sha and then push the complete objects into the results channel.
	// - Once the calcs waitgroup is done we close the results channel as well to let the uploader drain and finish.

	tmClient := transfermanager.New(client)
	calcs := make(chan UploadObject, 32) // mind that the size causes this channel to buffer which prevents deadlocks
	results := make(chan UploadObject, 32)

	calcsWg := sync.WaitGroup{}

	// The sha256 calculation workers.
	for i := 0; i < 4; i++ {
		calcsWg.Add(1)
		go func() {
			defer calcsWg.Done()
			for obj := range calcs {
				obj.SHA256 = sha256File(obj.Path)
				results <- obj
			}
		}()
	}

	// Once they are all done we can close the results channel.
	go func() {
		calcsWg.Wait()
		log.Println("All SHA256 calculations done, closing results channel")
		close(results)
	}()

	// The calcs channel gets fed by the walking of the upload tree.
	go func() {
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

			calcs <- UploadObject{
				ObjectName: objectName,
				Path:       path,
			}

			return nil
		})
		log.Println("Finished walking upload tree, closing calcs channel")
		close(calcs)
		if err != nil {
			log.Fatalln(err)
		}
	}()

	// Upload. This loop only ends when results is closed and drained.
	for res := range results {
		log.Println("Uploading", res.ObjectName, "from", res.Path)
		file, err := os.Open(res.Path)
		if err != nil {
			log.Fatalln("Failed to open file:", err)
		}
		_, err = tmClient.UploadObject(context.Background(), &transfermanager.UploadObjectInput{
			Bucket: aws.String(bucket),
			Key:    aws.String(res.ObjectName),
			Body:   file,
			Metadata: map[string]string{
				"X-KDE-SHA256": res.SHA256,
			},
		})
		if err != nil {
			log.Fatalln(err)
		}
	}
}

func main() {
	remote := flag.String("remote", "", "remote url to upload to, e.g. s3+https://s3.kde.org/kde-linux-images/sysupdate/v2/store")
	flag.Parse()

	remoteURI, err := url.Parse(*remote)
	if err != nil {
		log.Fatalln("Failed to parse remote URL:", err)
	}
	if remoteURI.Scheme != "s3+https" {
		log.Fatalln("Unsupported remote scheme:", remoteURI.Scheme)
	}
	if remoteURI.Host != "s3.kde.org" {
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

	log.Println("Connecting to MinIO at", remoteURI.Host)
	s3Client := connectToS3(remoteURI.Host)

	log.Println("Uploading to bucket", bucket, "with path prefix", path)
	upload(s3Client, bucket, path)
}
