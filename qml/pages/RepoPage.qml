import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations
    property bool __utilities_page

    property var repo: ({})
    property bool errorOccurred

    property int pageDepth
    onStatusChanged: if (status == PageStatus.Active) pageDepth = window.pageStack.depth
    PageStackProxy {
        id: pageStack
        depth: window.pageStack.depth = pageDepth
    }
    property alias pageStack: pageStack

    ListModel {
        id: utilitiesModel
        Component.onCompleted: {
            py.setHandler('error'+repo.hash, function() { errorOccurred = true; pulleyMenu.busy = false })
            py.setHandler('finished'+repo.hash, function() { pulleyMenu.busy = false })
            py.setHandler('utility'+repo.hash, append)
            py.setHandler('utilityUpdate'+repo.hash, function(hash, newData) {
                var i = findIndexByUrlHash(hash)
                if (i !== -1) set(i, newData)
            })

            py.call2('send_utilities', repo.hash)
        }

        Component.onDestruction: {
            py.setHandler('error'+repo.hash, undefined)
            py.setHandler('finished'+repo.hash, undefined)
            py.setHandler('utility'+repo.hash, undefined)
            py.call2('stop_utilities')
        }

        function findIndexByUrlHash(hash) {
            for(var i=0; i < count; i++)
                if (get(i).hash === hash) return i
            return -1
        }
    }

    SilicaListView {
        id: listView
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

        header: RepoHeader { repo: page.repo }

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

        property alias repo: page.repo
        delegate: UtilityDelegate {
            repo: listView.repo
            utility: model
        }
    }
}
