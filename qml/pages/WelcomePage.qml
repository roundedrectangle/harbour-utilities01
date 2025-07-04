import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    allowedOrientations: defaultAllowedOrientations
    property bool __utilities_page

    backNavigation: false
    onAccepted: config.welcomeTourCompleted = true

    SilicaListView {
        id: listView
        anchors.fill: parent
        /*width: parent.width
        anchors {
            top: header.bottom
            bottom: parent.bottom
        }*/

        model: [
            "https://raw.githubusercontent.com/roundedrectangle/utilities-repo/refs/heads/main/main.json",
        ]

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }

        header: Column {
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader { id: header }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                font.pixelSize: Theme.fontSizeExtraLarge
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                color: Theme.highlightColor
                text: qsTr("Welcome to Utilities!")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("Select default repositories to continue")
            }
        }

        delegate: ListItem {
            width: parent.width
            contentHeight: Theme.itemSizeMedium

            readonly property string url: listView.model[index]
            property bool turnedOn

            Row {
                x: Theme.horizontalPageMargin
                width: parent.width-2*x
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.paddingMedium

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - repoManageButton.width - 1*parent.spacing
                    truncationMode: TruncationMode.Fade
                    text: url
                }

                IconButton {
                    id: repoManageButton
                    icon.source: "image://theme/icon-m-" + (turnedOn ? "remove" : "add")
                    onClicked: py.call2((turnedOn ? 'remove' : 'add') + '_repo', url)
                }
            }

            Component.onCompleted: turnedOn = reposModel.findIndexByUrl(url) != '-1'

            Connections {
                target: reposModel
                onCountChanged: turnedOn = reposModel.findIndexByUrl(url) != '-1'
            }
        }
    }
}
