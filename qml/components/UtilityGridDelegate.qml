import QtQuick 2.0
import Sailfish.Silica 1.0

GridItem {
    id: gridItem
    property Page page
    property var repo
    property var utility

    enabled: utility.loaded

    contentHeight: column.height
    _backgroundColor: 'transparent' // press effect is provided by content

    Column {
        id: column
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Theme.paddingLarge
        }
        width: Theme.iconSizeLauncher
        spacing: Theme.paddingMedium

        Behavior on height { NumberAnimation { duration: 200 } }

        RoundedImage {
            id: roundedImage
            visible: true
            source: utility.icon
            rounded: utility.rounded_icon
            width: parent.width
            height: width
            highlighted: gridItem.highlighted

            BusyIndicator {
                id: busyIndicator
                anchors.centerIn: parent
                running: !utility.loaded
                size: BusyIndicatorSize.Small
            }
        }

        Label {
            id: label
            x: Theme.paddingSmall / 2
            width: parent.width - 2*x
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeExtraSmall
            fontSizeMode: Text.Fit
            minimumPixelSize: Theme.fontSizeTiny
            text: utility.name
            highlighted: gridItem.highlighted
            opacity: loaded ? 1 : Theme.opacityFaint
            Behavior on opacity { FadeAnimator {} }
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
