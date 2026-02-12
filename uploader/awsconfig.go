// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

package main

import (
	"errors"
	"os"
	"path/filepath"

	"gopkg.in/ini.v1"
)

type AWSSection struct {
	AccessKeyId  string `ini:"aws_access_key_id"`
	SecretKey    string `ini:"aws_secret_access_key"`
	SessionToken string `ini:"aws_session_token"`
}

func readConfigAWS(section string) (AWSSection, error) {
	awsSection := AWSSection{}

	awsConfigPath := filepath.Join(os.Getenv("HOME"), ".aws", "credentials")
	cfg, err := ini.Load(awsConfigPath)
	if err != nil {
		return awsSection, errors.New("failed to load AWS credentials file: " + err.Error())
	}

	err = cfg.Section(section).MapTo(&awsSection)
	if err != nil {
		return awsSection, errors.New("failed to map AWS credentials section: " + err.Error())
	}

	return awsSection, nil
}
