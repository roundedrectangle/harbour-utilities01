import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: root
    width: parent.width
    contentHeight: Theme.itemSizeSmall

    property var repo

    RoundedImage {
        id: roundedImage
        source: repo.icon
        rounded: repo.rounded_icon
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        width: Theme.iconSizeMedium
        height: Theme.iconSizeMedium
        highlighted: root.highlighted
    }

    Label {
        anchors {
            left: repo.icon ? roundedImage.right : parent.left
            leftMargin: repo.icon ? Theme.paddingMedium : Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        wrapMode: Text.Wrap
        text: repo.name
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
