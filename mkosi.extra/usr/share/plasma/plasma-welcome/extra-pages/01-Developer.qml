/*
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 *  SPDX-FileCopyrightText: 2024 Lasath Fernando <devel@lasath.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import Qt5Compat.GraphicalEffects

import org.kde.plasma.welcome

GenericPage {
    heading: i18nc("@info:window", "Developer?")
    description: i18nc("@info:usagetip", "KDE Linux is an immutable distro, meaning you can't make changes to a running system. Instead, you can develop in containers, such as distrobox.")

    topContent: [
        Kirigami.UrlButton {
            Layout.topMargin: Kirigami.Units.largeSpacing
            text: i18nc("@action:button", "Learn more")
            url: "https://distrobox.it/"
        }
    ]

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        Kirigami.Icon {
            id: image
            Layout.preferredWidth: Kirigami.Units.gridUnit * 20
            Layout.preferredHeight: Layout.preferredWidth

            source: "https://raw.githubusercontent.com/89luca89/distrobox/refs/heads/main/docs/assets/brand/svg/distrobox-light-vertical-color.svg"

            HoverHandler {
                id: hoverHandler
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: Controller.runCommand("flatpak run org.kde.konsole --noclose -e /bin/zsh -c \"DBX_NON_INTERACTIVE=true distrobox enter\" ");
            }

            QQC2.ToolTip {
                visible: hoverHandler.hovered
                text: i18nc("@action:button", "Create a KDE Linux distrobox")
            }

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 1
                radius: 20
                samples: 20
                color: Qt.rgba(0, 0, 0, 0.2)
            }
        }

        Kirigami.Heading {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Kirigami.Units.gridUnit
            text: i18nc("@title a friendly warning", "Click the button above to create a KDE Linux distrobox")
            wrapMode: Text.WordWrap
            level: 3
        }
    }
}
