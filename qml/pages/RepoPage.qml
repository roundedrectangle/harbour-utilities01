import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    property bool __utilities_page

    property var repo: ({})
    property bool errorOccurred

    property int pageDepth
    onStatusChanged: if (status == PageStatus.Active) pageDepth = window.pageStack.depth
    QtObject {
        id: pageStack
        property bool acceptAnimationRunning: window.pageStack.acceptAnimationRunning
        property bool busy: window.pageStack.busy
        property Component pageBackground: window.pageStack.pageBackground

        function push(page, properties, operationType) { window.pageStack.push(page, properties, operationType) }
        function pushAttached(page, properties, operationType) { window.pageStack.pushAttached(page, properties, operationType) }
        function completeAnimation() { window.pageStack.completeAnimation() }


        property int depth: window.pageStack.depth - page.pageDepth
        property Item currentPage: window.pageStack.currentPage.__utilities_page === 'undefined' ? window.pageStack.currentPage : null

        function find(func) {
            return window.pageStack.find(function(page) { return typeof page.__utilities_page === 'undefined' && func(page) })
        }
        function clear(func) {
            if (pageStack.currentPage.__utilities_page === 'undefined')
                window.pageStack.pop()
        }
        function pop(page, operationType) {
            if (typeof (page || window.pageStack.currentPage).__utilities_page === 'undefined')
                window.pageStack.pop(page, operationType)
        }
        function previousPage(fromPage) {
            var page = window.pageStack.previousPage(fromPage)
            if (page.__utilities_page === 'undefined') return page
        }
        function nextPage(fromPage) {
            var page = window.pageStack.nextPage(fromPage)
            if (page.__utilities_page === 'undefined') return page
        }
        function replace(page, properties, operationType) {
            if (pageStack.currentPage.__utilities_page === 'undefined')
                window.pageStack.replace(page, properties, operationType)
        }
        function navigateBack(operationType) {
            if (previousPage()) window.pageStack.navigateBack(operationType)
        }

        // TODO: do not allow modying or opening app's pages in page stack for these:
        function popAttached(page, operationType) {
            window.pageStack.popAttached(page, operationType)
        }
        function navigateForward(operationType) {
            window.pageStack.navigateForward(operationType)
        }
        function replaceAbove(existingPage, page, properties, operationType) {
            window.pageStack.replaceAbove(existingPage, page, properties, operationType)
            console.error("Utilities01: window.pageStack.replaceAbove not yet properly supported!")
        }
    }
    property alias pageStack: pageStack

    function pushTypedContent(type, content, error) {
        switch (type) {
        case 0:
            window.pageStack.push(Qt.createQmlObject(content, page, error))
            break
        case 1:
            window.pageStack.push(Qt.createComponent(content, Component.Asynchronous, page))
            break
        //default:
            // typically on -1, but unknown type will never happen and we now have other errors
            //shared.showError(qsTr("Could not load utility: unknown type"))
        }
    }

    ListModel {
        id: utilitiesModel
        Component.onCompleted: {
            py.setHandler('error'+repo.hash, function() { errorOccurred = true; pulleyMenu.busy = false })
            py.setHandler('finished'+repo.hash, function() { pulleyMenu.busy = false })
            py.setHandler('utility'+repo.hash, append)

            py.call2('send_utilities', repo.hash)
        }

        Component.onDestruction: {
            py.setHandler('error'+repo.hash, undefined)
            py.setHandler('finished'+repo.hash, undefined)
            py.setHandler('utility'+repo.hash, undefined)
            py.call2('stop_utilities')
        }
    }

    SilicaListView {
        anchors.fill: parent
        model: utilitiesModel

        PullDownMenu {
            id: pulleyMenu
            busy: true
            MenuItem {
                text: qsTr("Remove")
                onClicked: {
                    window.pageStack.pop()
                    Remorse.popupAction(reposPage, qsTr("Removed repository"), function() {
                        py.call2('remove_repo', [repo.url, repo.hash])
                    })
                }
            }
        }

        header: Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: repo.name
            }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width-2*x
                wrapMode: Text.Wrap
                text: repo.description
            }
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: utilitiesModel.count == 0 && !errorOccurred
        }

        ViewPlaceholder {
            anchors.fill: parent
            enabled: errorOccurred && utilitiesModel.count == 0
            text: qsTr("Could not load utilities")
        }

        delegate: ListItem {
            width: parent.width
            contentHeight: Theme.itemSizeMedium

            Column {
                id: delegateColumn
                x: Theme.horizontalPageMargin
                width: parent.width-2*x
                //anchors.bottomMargin: Theme.paddingLarge

                Label {
                    width: parent.width
                    truncationMode: TruncationMode.Fade
                    text: name
                }
            }

            onClicked: pushTypedContent(type, content, 'utility '+repo.hash+' '+name)

            menu: Component { ContextMenu {
                    hasContent: aboutMenuItem.visible || launchDetachedMenuItem.visible
                    MenuItem {
                        id: aboutMenuItem
                        visible: aboutType != -1
                        text: qsTr("About")
                        onClicked: pushTypedContent(aboutType, about, 'utilityAbout '+repo.hash+' '+name)
                    }
                    MenuItem {
                        id: launchDetachedMenuItem
                        visible: aboutType == 1
                        text: qsTr("Launch detached")
                        onClicked: py.call2('launch_detached', [repo.hash, hash])
                    }
                } }
        }
    }
}
