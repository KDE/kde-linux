// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>

package main

import (
	"context"
	"fmt"
	"path/filepath"
	"strings"

	"github.com/minio/minio-go/v7"
)

type S3Artifact struct {
	client    *minio.Client
	bucket    string
	path      string
	sha256Sum string
}

func (a S3Artifact) SHA256() string {
	if strings.HasSuffix(a.path, ".erofs.caibx") {
		// Never put the .erofs.caibx files into the SHA256SUMS it triggers a bug.
		// https://github.com/systemd/systemd/issues/38605
		return ""
	}

	return fmt.Sprintf("%s  %s", a.sha256Sum, filepath.Base(a.path))
}

func (a S3Artifact) Delete() error {
	return a.client.RemoveObject(context.Background(), a.bucket, a.path, minio.RemoveObjectOptions{})
}

func (a S3Artifact) Path() string {
	return a.path
}
