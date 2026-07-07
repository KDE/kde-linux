# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: stack

depends:
- os/deps-core.bst
- os/deps-middleware.bst
- os/deps-kde.bst
- os/deps-apps.bst
- os/deps-cli.bst
- kde-linux-packages.bst:kde-buildstream.bst:components/dbus-broker.bst
