/*
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 * SPDX-FileCopyrightText: 2026 Navya Sai Sadu <navyas.sadu@gmail.com>
 */

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.ki18n

Rectangle {
    id: root
    color: Kirigami.Theme.backgroundColor

    KLocalizedQmlContext {
        id: i18n
    }

    property int currentSlide: 0

    property var slides: [
        {
            image: "konqi-setup.png",
            headline: i18n.i18nc("@title", "Welcome to KDE Linux"),
            subtext: i18n.i18nc("@info", "Sit back while we set things up for you!")
        },
        {
            image: "katie.png",
            headline: i18n.i18nc("@title", "Built to be Safe"),
            subtext: i18n.i18nc("@info", "KDE Linux offers reliable system updates, and lets you roll back to older versions if there are any issues.")
        },
        {
            image: "konqi-plasma.png",
            headline: i18n.i18nc("@title", "Make it Yours"),
            subtext: i18n.i18nc("@info", "Set up the system the way you like with the customizability built into Plasma.")
        },
        {
            image: "konqi.png",
            headline: i18n.i18nc("@title", "Powered by Community"),
            subtext: i18n.i18nc("@info", "Built by passionate open source contributors!")
        }
    ]

    Timer {
        interval: 6000
        running: true
        repeat: true
        onTriggered: currentSlide = (currentSlide + 1) % slides.length
    }

   Repeater {
        model: root.slides.length
        Slide {
            required property int index

            anchors.fill: parent
            imageSource: slides[index].image
            headline: slides[index].headline
            subtext: slides[index].subtext
            active: currentSlide === index
            }
    }
}
