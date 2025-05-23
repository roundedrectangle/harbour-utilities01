import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    SilicaListView {
        anchors.fill: parent
        model: reposModel

        PullDownMenu {
            MenuItem {
                text: qsTr("Force refresh")
                onClicked: {
                    reposModel.clear()
                    py.call2('request_repos')
                }
            }

            MenuItem {
                text: qsTr("Add repo")
                onClicked: pageStack.push(addRepoDialog)

                Component {
                    id: addRepoDialog
                    Dialog {
                        onAccepted: py.call2('add_repo', urlField.text)
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

            function remove() {
                remorseAction(qsTr("Removed repository"), function() {
                    py.call2('remove_repo', [model.url, model.hash])
                })
            }

            menu: Component {
                ContextMenu {
                    MenuItem {
                        text: qsTr("Remove")
                        // puttings function directly (as lambda) make `py` undefined
                        onClicked: remove()
                    }
                }
            }

            onClicked: pageStack.push(Qt.resolvedUrl("RepoPage.qml"), {repo: model})
        }
    }
}
