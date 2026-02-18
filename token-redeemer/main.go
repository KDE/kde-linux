// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"

	"github.com/folbricht/desync"
	"gopkg.in/ini.v1"
)

type Credentials struct {
	AccessKeyId     string `json:"AccessKeyId"`
	SecretAccessKey string `json:"SecretAccessKey"`
	SessionToken    string `json:"SessionToken"`
	// e.g. "Expiration":"Mon, 15 Sep 2025 10:17:16 GMT"
	Expiration string `json:"Expiration"`
}

// S3Creds holds credentials or references to an S3 credentials file.
type DesyncS3Creds struct {
	AccessKey          string `json:"access-key,omitempty"`
	SecretKey          string `json:"secret-key,omitempty"`
	AwsCredentialsFile string `json:"aws-credentials-file,omitempty"`
	AwsProfile         string `json:"aws-profile,omitempty"`
	// Having an explicit aws region makes minio slightly faster because it avoids url parsing
	AwsRegion string `json:"aws-region,omitempty"`
}

// Config is used to hold the global tool configuration. It's used to customize
// store features and provide credentials where needed.
type DesyncConfig struct {
	S3Credentials map[string]DesyncS3Creds       `json:"s3-credentials"`
	StoreOptions  map[string]desync.StoreOptions `json:"store-options"`
}

type AWSSection struct {
	AccessKeyId  string `ini:"aws_access_key_id"`
	SecretKey    string `ini:"aws_secret_access_key"`
	SessionToken string `ini:"aws_session_token"`
}

type Redeemer struct {
	tokensUrl        string
	desyncConfigPath string
	awsConfigPath    string
}

func (r *Redeemer) redeem(oidc string) Credentials {
	if oidc == "" {
		log.Fatal("MINIO_OIDC environment variable not set")
	}

	response, err := http.PostForm(r.tokensUrl, url.Values{"token": {oidc}})
	if err != nil {
		log.Fatalln("Failed to redeem token:", err)
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(response.Body)
		log.Fatalln("Failed to redeem token:", response.Status, string(body))
	}

	var creds Credentials
	decoder := json.NewDecoder(response.Body)
	decoder.DisallowUnknownFields() // Do not allow unexpected fields lest we ignore something important!
	err = decoder.Decode(&creds)
	if err != nil {
		body, _ := io.ReadAll(response.Body)
		log.Fatalln("Failed to decode credentials:", err, response.Status, string(body))
	}

	if creds.AccessKeyId == "" {
		log.Fatalln("Received empty access key ID")
	}

	return creds
}

func (r *Redeemer) writeConfigAWS(creds Credentials) {
	a := &AWSSection{
		AccessKeyId:  creds.AccessKeyId,
		SecretKey:    creds.SecretAccessKey,
		SessionToken: creds.SessionToken,
	}

	cfg := ini.Empty()
	section := cfg.Section("default")
	err := section.ReflectFrom(a)
	if err != nil {
		log.Fatal(err)
	}

	err = os.MkdirAll(filepath.Dir(r.awsConfigPath), 0700)
	if err != nil {
		log.Fatal(err)
	}

	err = cfg.SaveTo(r.awsConfigPath)
	if err != nil {
		log.Fatal(err)
	}
}

func (r *Redeemer) writeConfigDesync(creds Credentials) {
	config := DesyncConfig{
		S3Credentials: map[string]DesyncS3Creds{
			"https://storage.kde.org": {
				AwsCredentialsFile: r.awsConfigPath,
			},
		},
		StoreOptions: map[string]desync.StoreOptions{},
	}
	configData, err := json.Marshal(config)
	if err != nil {
		log.Fatal(err)
	}
	if len(configData) == 0 {
		log.Fatal("Generated empty config")
	}

	err = os.MkdirAll(filepath.Dir(r.desyncConfigPath), 0700)
	if err != nil {
		log.Fatal(err)
	}

	log.Println("Writing desync config to", r.desyncConfigPath)
	log.Println("Config content:", string(configData))
	err = os.WriteFile(r.desyncConfigPath, configData, 0600)
	if err != nil {
		log.Fatal(err)
	}
}

func (r *Redeemer) writeConfig(creds Credentials) {
	r.writeConfigDesync(creds)
	r.writeConfigAWS(creds)
}

func main() {
	home, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}

	redeemer := Redeemer{
		tokensUrl:        "https://tokens.kde.org/minio/gitlab",
		desyncConfigPath: home + "/.config/desync/config.json",
		awsConfigPath:    home + "/.aws/credentials",
	}
	creds := redeemer.redeem(os.Getenv("MINIO_OIDC"))
	redeemer.writeConfig(creds)
}
