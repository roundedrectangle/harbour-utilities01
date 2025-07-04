import QtQuick 2.0
import Sailfish.Silica 1.0
import "../modules/Opal/Tabs"

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations
    property bool __utilities_page

    Timer {
        id: welcomePageTimer
        interval: 0
        onTriggered: pageStack.push(Qt.resolvedUrl("WelcomePage.qml"))
    }

    Component.onCompleted: {
        if (!config.welcomeTourCompleted) {
            pageStack.completeAnimation()
            welcomePageTimer.start()
        }
    }

    TabView {
        anchors.fill: parent

        Tab {
            title: qsTr("Home")

            Component {
                TabItem {
                    flickable: flick
                    SilicaFlickable {
                        id: flick
                        anchors.fill: parent
                        contentHeight: column.height

                        PullDownMenu {
                            MenuItem {
                                text: qsTr("About")
                                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                            }
                            MenuItem {
                                text: qsTr("Settings")
                                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
                            }
                        }

                        Column {
                            id: column

                            width: page.width
                            spacing: Theme.paddingLarge
                            Label {
                                x: Theme.horizontalPageMargin
                                text: qsTr("Hello Sailors")
                                color: Theme.secondaryHighlightColor
                                font.pixelSize: Theme.fontSizeExtraLarge
                            }
                        }
                    }
                }
            }
        }

        Tab {
            title: qsTr("Repositories")
            Component { TabItem {
                    flickable: reposFlick
                    ReposTab { id: reposFlick }
                } }
        }
    }
}
