# SPDX-FileCopyrightText: 2025 Aleix Pol Gonzalez <aleix.pol@codethink.co.uk>
# SPDX-License-Identifier: BSD-2-Clause

kind: stack

depends:
- components/plasma-login-manager.bst
- components/plasma-discover.bst
- components/kdeplasma-addons.bst
- components/kpmcore.bst # needed by calamares
- components/polkit-kde-agent.bst
- org.kde.plasma.desktop.bst # kde-linux

# KDE Linux needs GCC and such installed so that it can build calamares
- components/yamlcpp.bst
- os/os-release.bst
