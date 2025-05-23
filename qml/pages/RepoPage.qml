import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property var repo: ({})
    property bool errorOccurred

    ListModel {
        id: utilitiesModel
        Component.onCompleted: {
            py.setHandler('error'+repo.hash, function() { errorOccurred = true })
            py.setHandler('utility'+repo.hash, append)

            py.call2('send_utilities', repo.hash)
        }

        Component.onDestruction: {
            py.setHandler('error'+repo.hash, undefined)
            py.setHandler('utility'+repo.hash, undefined)
        }
    }

    SilicaListView {
        anchors.fill: parent
        model: utilitiesModel

        PullDownMenu {
            MenuItem {
                text: qsTr("Remove")
                onClicked: {
                    pageStack.pop()
                    remove()
                }
            }
        }

        header: Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: repo.name
            }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width-2*x
                wrapMode: Text.Wrap
                text: repo.description
            }
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: utilitiesModel.count == 0 && !errorOccurred
        }

        ViewPlaceholder {
            anchors.fill: parent
            enabled: errorOccurred && utilitiesModel.count == 0
            text: qsTr("Could not load utilities")
        }

        delegate: ListItem {
            width: parent.width
            contentHeight: Theme.itemSizeMedium

            Column {
                id: delegateColumn
                x: Theme.horizontalPageMargin
                width: parent.width-2*x
                //anchors.bottomMargin: Theme.paddingLarge

                Label {
                    width: parent.width
                    truncationMode: TruncationMode.Fade
                    text: name
                }
            }
        }
    }
}
