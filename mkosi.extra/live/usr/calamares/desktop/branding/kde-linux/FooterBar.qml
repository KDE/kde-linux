// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC

import org.kde.kirigami as Kirigami
import io.calamares.ui as Calamares

RowLayout {
    spacing: Kirigami.Units.smallSpacing

    Item { Layout.fillWidth: true }

    QQC.Button {
        action: Kirigami.Action {
            enabled: Calamares.ViewManager.backEnabled
            text: Calamares.ViewManager.backLabel
            icon.name: Calamares.ViewManager.backIcon
            onTriggered: Calamares.ViewManager.back()
        }
    }

    QQC.Button {
        action: Kirigami.Action {
            enabled: Calamares.ViewManager.nextEnabled
            text: Calamares.ViewManager.nextLabel
            icon.name: Calamares.ViewManager.nextIcon
            onTriggered: Calamares.ViewManager.next()
        }
    }

    QQC.Button {
        action: Kirigami.Action {
            enabled: Calamares.ViewManager.quitEnabled
            visible: Calamares.ViewManager.quitVisible
            text: Calamares.ViewManager.quitLabel
            icon.name: Calamares.ViewManager.quitIcon
            onTriggered: Calamares.ViewManager.quit()
        }
    }
}
