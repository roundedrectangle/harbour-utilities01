import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    backNavigation: false
    onAccepted: config.welcomeTourCompleted = true

    Column {
        anchors.fill: parent
        spacing: Theme.paddingLarge

        DialogHeader { title: qsTr("Welcome to Utilities!") }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Select default repositories")
        }
    }
}
