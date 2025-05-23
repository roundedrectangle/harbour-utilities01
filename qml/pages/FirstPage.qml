import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    Timer {
        id: welcomePageTimer
        interval: 0
        onTriggered: pageStack.push(Qt.resolvedUrl("WelcomePage.qml"))
    }

    Component.onCompleted: {
        if (!config.welcomeTourCompleted) {
            pageStack.completeAnimation()
            welcomePageTimer.start()
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Repositories")
                onClicked: pageStack.push(Qt.resolvedUrl('ReposPage.qml'))
            }
        }

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("UI Template")
            }
            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Hello Sailors")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
    }
}
