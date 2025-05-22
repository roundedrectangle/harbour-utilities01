import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    SilicaListView {
        anchors.fill: parent
        model: reposModel

        PullDownMenu {
            MenuItem {
                text: qsTr("Add repo")
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("SettingsPage.qml"))

                Component {
                    id: addRepoDialog
                    Dialog {
                        onAccepted: py.runAndSendRepo('add_repo', urlField.text)
                        Column {
                            width: parent.width
                            DialogHeader {}

                            TextField {
                                id: urlField
                                width: parent.width
                                label: "URL"
                            }
                        }
                    }
                }
            }
        }

        header: PageHeader { title: qsTr("Repositories") }

        delegate: ListItem {
            width: parent.width
            contentHeight: delegateColumn.height

            Column {
                id: delegateColumn
                x: Theme.horizontalPageMargin
                width: parent.width-2*x
                anchors.bottomMargin: Theme.paddingLarge

                Label {
                    text: name
                }
            }

            menu: Component {
                ContextMenu {
                    MenuItem {
                        text: qsTr("Remove")
                        onClicked: remorseAction(qsTr("Removed repository"), function() {
                            py.call2('remove_repo', [url, hash])
                        })
                    }
                }
            }
        }
    }
}
