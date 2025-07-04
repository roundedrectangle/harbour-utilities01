import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: reposPage
    allowedOrientations: defaultAllowedOrientations
    property bool __utilities_page

    SilicaListView {
        anchors.fill: parent
        model: reposModel

        PullDownMenu {
            busy: !reposModel.loaded
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
                        text: qsTr("Copy URL")
                        onClicked: Clipboard.text = model.url
                    }
                    MenuItem {
                        text: qsTr("Remove")
                        // putting function directly (as lambda) makes `py` undefined
                        onClicked: remove()
                    }
                    MenuItem {
                        text: qsTr("Reload")
                        onClicked: py.call2('reload_repo', [model.url, model.hash])
                    }
                }
            }

            onClicked: pageStack.push(Qt.resolvedUrl("RepoPage.qml"), {repo: model})
        }
    }
}
