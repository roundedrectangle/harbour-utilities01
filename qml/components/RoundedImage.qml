import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

HighlightImage {
    id: image
    property bool rounded
    visible: !!source && source != ''

    sourceSize {
        width: width
        height: height
    }

    layer.enabled: rounded
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: image.width
            height: image.height
            radius: Math.min(width, height)
        }
    }

    BusyIndicator {
        z: 2
        anchors.centerIn: parent
        size: BusyIndicatorSize.Medium
        running: image.status === Image.Loading
    }
}
