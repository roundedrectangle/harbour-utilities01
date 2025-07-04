import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    width: parent.width
    contentHeight: Theme.itemSizeMedium

    property var repo

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
            py.call2('remove_repo', [repo.url, repo.hash])
        })
    }

    menu: Component {
        ContextMenu {
            MenuItem {
                text: qsTr("Copy URL")
                onClicked: Clipboard.text = repo.url
            }
            MenuItem {
                text: qsTr("Remove")
                // putting function directly (as lambda) makes `py` undefined
                onClicked: remove()
            }
            MenuItem {
                text: qsTr("Reload")
                onClicked: py.call2('reload_repo', [repo.url, repo.hash])
            }
        }
    }

    onClicked: pageStack.push(Qt.resolvedUrl("RepoPage.qml"), {repo: repo})
}
