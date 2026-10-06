/*
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 * SPDX-FileCopyrightText: 2026 Navya Sai Sadu <navyas.sadu@gmail.com>
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    property string imageSource: ""
    property string headline: ""
    property string subtext: ""
    property bool active: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.gridUnit

        Image {
            source: imageSource
            fillMode: Image.PreserveAspectFit
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: active
        }

        Kirigami.Heading {
            text: headline
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            visible: active
        }

        QQC2.Label {
            text: subtext
            wrapMode: Text.Wrap
            color: Kirigami.Theme.disabledTextColor
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            visible: active
        }
    }
}
