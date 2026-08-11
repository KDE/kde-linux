// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2024 Harald Sitter <sitter@kde.org>
// SPDX-FileCopyrightText: 2026 Hadi Chokr <hadichokr@icloud.com>

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC

import org.kde.kirigami as Kirigami
import io.calamares.ui as Calamares

RowLayout {
    readonly property var stepIcons: ({
        "welcome": "kde-symbolic",
        "locale": "globe-symbolic",
        "keyboard": "input-keyboard-symbolic",
        "partition": "drive-multipartition-symbolic",
        "users": "system-users-symbolic",
        "exec": "run-install-symbolic",
        "finished": "run-install-symbolic"
    })

    RowLayout {
        Layout.fillWidth: true
        Kirigami.Icon {
            // TODO should be the page icon but calamares has no actual notion of icons for pages
            source: {
                const step = Calamares.ViewManager.currentStepName
                return control.stepIcons[step] || "kde-symbolic"
            }
        }
        Kirigami.Heading {
            Layout.fillWidth: true
            text: progressRepeater.itemAt(control.currentIndex).text
        }
    }

    QQC.Control {
        id: control
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        spacing: Kirigami.Units.mediumSpacing

        property int currentIndex: Calamares.ViewManager.currentStepIndex
        readonly property var stepIcons: parent.stepIcons

        Rectangle {
            id: backgroundLine

            x: {
                progressRepeater.count // bind
                const first = progressRepeater.itemAt(0).dot
                return first.x + first.width / 2.0
            }

            y: {
                progressRepeater.count // bind
                const first = progressRepeater.itemAt(0).dot
                return (first.y + first.height / 2.0) - (backgroundLine.height / 2.0)
            }

            height: {
                progressRepeater.count // bind
                const first = progressRepeater.itemAt(0).dot
                return first.implicitHeight / 4.0
            }

            width: {
                progressRepeater.count // bind
                control.currentIndex // bind
                const last = progressRepeater.itemAt(progressRepeater.count - 1).dot
                // It is entirely unclear to me why this requires manual mapping while the coordinates don't
                const lastPoint = mapFromItem(last, last.x, last.y)
                return lastPoint.x + last.width / 2.0
            }

            color: Kirigami.Theme.disabledTextColor
        }

        Rectangle {
            id: progressor
            anchors.left: backgroundLine.left
            anchors.top: backgroundLine.top
            anchors.bottom: backgroundLine.bottom

            width: {
                const current = progressRepeater.itemAt(control.currentIndex).dot
                const currentPoint = mapFromItem(current, current.x, current.y)
                const currentCenter = currentPoint.x + current.width
                console.assert(currentCenter > progressor.x)
                return currentCenter - progressor.x
            }

            color: Kirigami.Theme.highlightColor
            Behavior on width {
                SequentialAnimation {
                    NumberAnimation {
                        duration: Kirigami.Units.shortDuration
                    }
                    ScriptAction {
                        script: {
                            for (let i = 0; i < progressRepeater.count; i++) {
                                progressRepeater.itemAt(i).done = control.currentIndex >= i
                            }
                        }
                    }
                }
            }
        }

        Row {
            id: row
            spacing: control.spacing * 8

            Repeater {
                id: progressRepeater
                model: Calamares.ViewManager
                delegate: ColumnLayout {
                    property bool done: false
                    readonly property alias dot: _rectangle
                    readonly property alias text: _label.text

                    Kirigami.ShadowedRectangle {
                        Layout.alignment: Qt.AlignHCenter
                        id: _rectangle
                        implicitWidth: implicitHeight
                        implicitHeight: Kirigami.Units.gridUnit

                        radius: height / 2.0
                        color: (index === 0 || done) ? progressor.color : backgroundLine.color
                    }

                    QQC.Label {
                        id: _label
                        text: display
                        color: backgroundLine.color
                        opacity: 0.8
                    }
                }
            }
        }
    }
}
