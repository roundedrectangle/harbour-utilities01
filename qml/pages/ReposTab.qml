import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

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

    delegate: RepoDelegate { repo: model }
}
