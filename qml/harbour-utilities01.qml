import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.0
import Nemo.Configuration 1.0
import Nemo.DBus 2.0
import "pages"

ApplicationWindow {
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    // there were some issues with pyotherside.atexit() in sailcord, don't remember which exactly
    Component.onDestroyed: py.call_sync('main.disconnect')

    ConfigurationGroup {
        id: config
        path: "/apps/harbour-utilities01"

        function removeValue(key) {
            if (value(key, null) !== null)
                setValue(key, undefined)
        }

        property bool welcomeTourCompleted

        // Settings

    }

    DBusInterface {
        id: globalProxy
        bus: DBus.SystemBus
        service: 'net.connman'
        path: '/'
        iface: 'org.sailfishos.connman.GlobalProxy'

        //signalsEnabled: true
        //function propertyChanged(name, value) { updateProxy() }

        // Only set proxy one time (for now)
        property string url
        Component.onCompleted: updateProxy()
        onUrlChanged: py.init(url)

        function updateProxy() {
            // Sets the `url` to the global proxy URL, if enabled. Only manual proxy is supported, only the first address is used and excludes are not supported: FIXME
            // When passing only one parameter, you can pass it without putting it into an array (aka [] brackets)
            typedCall('GetProperty', {type: 's', value: 'Active'}, function (active){
                if (active) typedCall('GetProperty', {type: 's', value: 'Configuration'}, function(conf) {
                    if (conf['Method'] === 'manual') url = conf['Servers'][0]
                    else url=''
                }, function(e){url=''}); else url=''
            }, function(e){url=''})
        }
    }

    QtObject {
        id: shared


    }

    Python {
        id: py
        property bool initialized

        onError: shared.showError(qsTranslate("Errors", "Python error"), traceback)
        onReceived: console.log("got message from python: " + data)

        function call2(name, args, callback) { call('main.comm.'+name, typeof args === 'undefined' ? [] : (Array.isArray(args) ? args : [args]), callback) }

        function init(proxy) {
            if (initialized) return
            addImportPath(Qt.resolvedUrl('../lib/deps'))
            addImportPath(Qt.resolvedUrl('../python'))
            importModule('main', function() {
                call2('set_proxy', function() {
                    reloadConstants(function() {initialized=true})
                })
            })
        }

        function reloadConstants(callback) {
            call2('set_constants', [], callback)
        }
    }
}
