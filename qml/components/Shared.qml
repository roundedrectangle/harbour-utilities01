import QtQuick 2.0

QtObject {
    property bool active: Qt.application.state === Qt.ApplicationActive

    // Notifications/errors
    function showInfo(summary, text) {
        notifier.appIcon = "image://theme/icon-lock-information"
        notifier.summary = summary || ''
        notifier.body = text || ''
        notifier.publish()
    }

    function showError(summary, text) {
        notifier.appIcon = "image://theme/icon-lock-warning"
        notifier.summary = summary || ''
        notifier.body = text || ''
        notifier.publish()
        console.log("error", summary, text)
    }
}
