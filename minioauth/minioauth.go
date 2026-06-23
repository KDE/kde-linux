// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>
// SPDX-FileCopyrightText: 2026 Thomas Duckworth <tduck@filotimoproject.org>

package minioauth

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
	"gopkg.in/ini.v1"
)

type AWSSection struct {
	AccessKeyID  string `ini:"aws_access_key_id"`
	SecretKey    string `ini:"aws_secret_access_key"`
	SessionToken string `ini:"aws_session_token"`
}

func readConfigAWS(section string) (AWSSection, error) {
	awsSection := AWSSection{}

	awsConfigPath := filepath.Join(os.Getenv("HOME"), ".aws", "credentials")
	cfg, err := ini.Load(awsConfigPath)
	if err != nil {
		return awsSection, fmt.Errorf("failed to load AWS credentials file: %w", err)
	}

	err = cfg.Section(section).MapTo(&awsSection)
	if err != nil {
		return awsSection, fmt.Errorf("failed to map AWS credentials section: %w", err)
	}

	return awsSection, nil
}

func Connect(endpoint string) (*minio.Client, error) {
	awsSection, err := readConfigAWS("default")
	if err != nil {
		return nil, err
	}
	if awsSection.AccessKeyID == "" {
		return nil, errors.New("AWS access key ID is empty")
	}
	if awsSection.SecretKey == "" {
		return nil, errors.New("AWS secret access key is empty")
	}
	if awsSection.SessionToken == "" {
		return nil, errors.New("AWS session token is empty")
	}

	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:           credentials.NewStaticV4(awsSection.AccessKeyID, awsSection.SecretKey, awsSection.SessionToken),
		Secure:          true,
		TrailingHeaders: true,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create MinIO client: %w", err)
	}

	return minioClient, nil
}

func ListBuckets(client *minio.Client) ([]minio.BucketInfo, error) {
	return client.ListBuckets(context.Background())
}
