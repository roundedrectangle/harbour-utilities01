import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.0
import "pages"

ApplicationWindow {
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("../python"))
            importModule('main', function() {
                reloadConstants()
                initialized = true
            })
        }

        onError: shared.showError(qsTranslate("Errors", "Python error"), traceback)
        onReceived: console.log("got message from python: " + data)

        function call2(name, args, callback) { call('main.comm.'+name, typeof args === 'undefined' ? [] : (Array.isArray(args) ? args : [args]), callback) }

        function reloadConstants() {
            call2('set_constants', [])
        }
    }
}
