// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>

package main

type Artifact interface {
	Path() string
	// A SHA256 string with filename. Separated by two spaces. Never includes dirname!
	SHA256() string
	Delete() error
}
