import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader { title: qsTr("Settings") }

            Slider {
                value: config.cachePeriod
                minimumValue: 0
                maximumValue: 7
                stepSize: 1
                width: parent.width
                valueText: switch (value) {
                   default: case 0: return qsTr("Never")
                   case 1: return qsTr("On app restart")
                   case 2: return qsTr("Hourly")
                   case 3: return qsTr("Daily")
                   case 4: return qsTr("Weekly")
                   case 5: return qsTr("Monthly")
                   case 6: return qsTr("Half-yearly")
                   case 7: return qsTr("Yearly")
                }

                label: "Cache update period"

                onValueChanged: config.cachePeriod = value
            }

            Label {
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                text: qsTr("Changes how often the cache is updated. App restart might be required")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                bottomPadding: Theme.paddingMedium
            }

            SectionHeader { text: qsTr("Debugging") }
            TextSwitch {
                text: qsTr("Show info messages in notifications")
                checked: config.infoInNotifications
                onCheckedChanged: config.infoInNotifications = checked
            }
        }
    }
}
