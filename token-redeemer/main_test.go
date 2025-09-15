// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2025 Harald Sitter <sitter@kde.org>

package main

import (
	"net"
	"net/http"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

type tokenServer struct{}

func (t *tokenServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{
		"AccessKeyId": "access",
		"SecretAccessKey": "secret",
		"SessionToken": "session"
	}`))
}

func TestRedeemer(t *testing.T) {
	server := &http.Server{Addr: "localhost:0", Handler: &tokenServer{}}
	listener, err := net.Listen("tcp", server.Addr)
	assert.Nil(t, err)
	go server.Serve(listener)

	r := &Redeemer{
		tokensUrl:        "http://" + listener.Addr().String(),
		desyncConfigPath: "/tmp/desync.json",
		awsConfigPath:    "/tmp/aws-credentials",
	}
	creds := r.redeem("oidc")
	assert.Equal(t, "access", creds.AccessKeyId)
	assert.Equal(t, "secret", creds.SecretAccessKey)
	assert.Equal(t, "session", creds.SessionToken)
	r.writeConfig(creds)

	{
		info, err := os.Stat(r.desyncConfigPath)
		assert.Nil(t, err)
		assert.True(t, info.Size() > 4)
	}

	{
		info, err := os.Stat(r.awsConfigPath)
		assert.Nil(t, err)
		assert.True(t, info.Size() > 4)
	}
}
