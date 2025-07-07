import QtQuick 2.5
import Sailfish.Silica 1.0
import "../components"

Page {
    id: repoPage
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
    property alias repoPage: repoPage
    property var pulleyMenu: loader.item ? loader.item.pullDownMenu : null

    ListModel {
        id: utilitiesModel
        Component.onCompleted: {
            py.setHandler('error'+repo.hash, function() {
                errorOccurred = true
                if (pulleyMenu) pulleyMenu.busy = false
            })
            py.setHandler('finished'+repo.hash, function() { if (pulleyMenu) pulleyMenu.busy = false })
            py.setHandler('utility'+repo.hash, append)
            py.setHandler('utilityUpdate'+repo.hash, function(hash, newData) {
                var i = findIndexByUrlHash(hash)
                if (i !== -1) set(i, newData)
            })
            py.setHandler('utilityIcon'+repo.hash, function(hash, icon) {
                var i = findIndexByUrlHash(hash)
                if (i !== -1) setProperty(i, 'icon', icon)
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

    Component {
        id: pulleyMenuComponent
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
    }
    Component {
        id: headerComponent
        RepoHeader {
            repo: repoPage.repo
            anchors.bottomMargin: Theme.paddingLarge*15
        }
    }
    Component {
        id: viewPlaceholderComponent
        ViewPlaceholder {
            anchors.fill: parent
            enabled: errorOccurred && utilitiesModel.count == 0
            text: qsTr("Could not load utilities")
        }
    }

    PageBusyIndicator {
        running: utilitiesModel.count == 0 && !errorOccurred
    }


    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: false ? listViewComponent : gridViewComponent
    }

    Component {
        id: listViewComponent
        SilicaListView {
            id: listView
            anchors.fill: parent
            model: utilitiesModel

            Loader { sourceComponent: pulleyMenuComponent }
            header: headerComponent

            Loader {
                sourceComponent: viewPlaceholderComponent
                active: errorOccurred && utilitiesModel.count == 0
            }

            property var repo: repoPage.repo
            delegate: UtilityDelegate {
                page: repoPage
                repo: listView.repo
                utility: model
            }
        }
    }

    Component {
        id: gridViewComponent
        SilicaGridView {
            id: gridView
            height: parent.height
            model: utilitiesModel

            Loader { sourceComponent: pulleyMenuComponent }
            header: headerComponent
            Binding {
                when: !!target
                target: headerItem
                property: 'anchors.bottomMargin'
                value: Theme.paddingLarge*15
            }

            Loader {
                sourceComponent: viewPlaceholderComponent
                active: errorOccurred && utilitiesModel.count == 0
            }

            FontMetrics {
                id: fontMetrics
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            property int columns: 4 // TODO
            cellWidth: width / columns
            cellHeight: Theme.iconSizeLarge + Theme.paddingMedium +  fontMetrics.height + Theme.paddingLarge

            property var repo: repoPage.repo
            delegate: UtilityGridDelegate {
                page: repoPage
                repo: gridView.repo
                utility: model
            }
        }
    }
}
