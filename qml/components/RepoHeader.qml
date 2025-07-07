import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

Item {
    width: parent.width
    implicitHeight: bannerLoader.active ? width / 2 : header.height
    property var repo

    Loader {
        id: bannerLoader
        width: parent.width
        height: width / 2
        active: !!repo.banner
        sourceComponent: Component {
            Image {
                anchors.fill: parent
                sourceSize {
                    width: width
                    height: height
                }
                source: repo.banner
                Rectangle {
                    width: parent.width
                    height: header.height + Theme.paddingLarge
                    anchors.bottom: parent.bottom
                    gradient: Gradient {
                        GradientStop { position: 1.0; color: Theme.rgba('black', Theme.opacityOverlay) }
                        GradientStop { position: 0.0; color: 'transparent' }
                    }
                }
            }
        }
    }
    PageHeader {
        id: header
        width: parent.width
        title: repo.name
        description: repo.description
        z: 1
        anchors.bottom: parent.bottom

        Loader {
            active: !!repo.icon
            parent: header.extraContent
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: RoundedImage {
                source: repo.icon
                rounded: repo.rounded_icon
                width: Theme.iconSizeLarge
                height: width
            }
        }
    }
}
