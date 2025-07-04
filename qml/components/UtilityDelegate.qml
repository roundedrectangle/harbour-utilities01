import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    property Page page
    property var repo
    property var utility

    width: parent.width
    contentHeight: delegateColumn.height
    enabled: utility.loaded

    Row {
        id: delegateColumn
        x: Theme.horizontalPageMargin
        width: parent.width-2*x
        height: Theme.itemSizeSmall

        //Image {}

        Label {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - busyIndicator.width - (parent.visibleChildren.length - 1)*parent.spacing
            truncationMode: TruncationMode.Fade
            text: utility.name
            Behavior on width { NumberAnimation { duration: 200 } }
            opacity: loaded ? 1 : Theme.opacityFaint
        }

        BusyIndicator {
            id: busyIndicator
            anchors.verticalCenter: parent.verticalCenter
            running: !utility.loaded
            size: BusyIndicatorSize.Small
        }
    }

    onClicked: shared.pushTypedContent(utility.type, utility.content, 'utility '+repo.hash+' '+utility.name, page)

    menu: Component { ContextMenu {
            hasContent: aboutMenuItem.visible || launchDetachedMenuItem.visible
            MenuItem {
                id: aboutMenuItem
                visible: utility.aboutType != -1
                text: qsTr("About")
                onClicked: shared.pushTypedContent(utility.aboutType, utility.about, 'utilityAbout '+repo.hash+' '+utility.name, page)
            }
            MenuItem {
                id: launchDetachedMenuItem
                visible: utility.type == 1
                text: qsTr("Launch detached")
                onClicked: py.call2('launch_detached', [repo.hash, utility.hash])
            }
        } }
}
