import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property bool __utilities_page

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
                   default: case 0: return qsTr("On app restart")
                   case 1: return qsTr("Hourly")
                   case 2: return qsTr("Daily")
                   case 3: return qsTr("Weekly")
                   case 4: return qsTr("Monthly")
                   case 5: return qsTr("Half-yearly")
                   case 6: return qsTr("Yearly")
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

            ButtonLayout {
                Button {
                    text: qsTr("Reset tutorial")
                    onClicked: config.welcomeTourCompleted = false
                }
                Button {
                    text: qsTr("Clear cache")
                    onClicked: py.call2('clear_cache')
                }
                Button {
                    text: qsTr("Open welcome page")
                    onClicked: pageStack.push(Qt.resolvedUrl("WelcomePage.qml"), {backNavigation: true})
                }
            }
        }
    }
}
