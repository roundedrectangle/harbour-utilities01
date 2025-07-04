import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import Nemo.DBus 2.0
import "pages"
import 'components'

ApplicationWindow {
    id: window
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    // there were some issues with pyotherside.atexit() in sailcord, don't remember which exactly
    Component.onDestruction: py.call_sync('main.disconnect')

    Notification { // Notifies about app status
        id: notifier
        replacesId: 0
        onReplacesIdChanged: if (replacesId !== 0) replacesId = 0
        isTransient: !config.infoInNotifications
    }

    ConfigurationGroup {
        id: config
        path: "/apps/harbour-utilities01"

        onCachePeriodChanged: py.call2('set_cache_period', cachePeriod)

        function removeValue(key) {
            if (value(key, null) !== null)
                setValue(key, undefined)
        }

        property bool welcomeTourCompleted

        // Settings
        property bool infoInNotifications
        property int cachePeriod: 0
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
        // UPD: we still only set it one time, but we initialize before proxy is detected
        property string url
        Component.onCompleted: updateProxy()
        onUrlChanged: py.call2('set_proxy', url)

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

    Shared { id: shared }

    Python {
        id: py
        property bool initialized

        onError: shared.showError(qsTranslate("Errors", "Python error"), traceback)
        onReceived: console.log("got message from python: " + data)

        function call2(name, args, callback) { call('main.'+name, typeof args === 'undefined' ? [] : (Array.isArray(args) ? args : [args]), callback) }

        Component.onCompleted: {
            if (initialized) return

            var errorStrings = {
                'unknown': qsTr("Unknown error"), // This should not happen
                'json': qsTr("Unknown JSON decode error"),
                'model': qsTr("Unknown cattrs model construction error"),

                // Config
                'configLoadJSON': qsTranslate("Errors", "Unable to load config '%1': invalid JSON data. Resetting to default"),
                'configLoadPermissions': qsTranslate("Errors", "Unable to load config '%1': insufficient permissions"),
                'configSavePermissions': qsTranslate("Errors", "Unable to save config '%1': insufficient permissions"),
                'configSaveNotFound': qsTranslate("Errors", "Unable to save config '%1': file not found"),
                'configSaveJSON': qsTranslate("Errors", "Unable to save config '%1': invalid JSON data."),
                'configDirPermissions': qsTranslate("Errors", "Unable to create directory for config '%1': insufficient permissions"),

                'configLoadCattrs': qsTranslate("Errors", "Unable to load config '%1': could not load cattrs model. Resetting to default"),

                'json_repository': qsTr("Invalid JSON in a repository"),
                'model_repository': qsTr("Invalid model in a repository."),
                'utilitiesRepoCacheNotFound': qsTr("Cached repo was not found in cache"),
                'utilityAboutArchiveNotAllowed': qsTr("Archived about page not allowed"),
                'utilityDetachInvalidType': qsTr("Could not start detached utility: unsupported type"),
                'detachError': qsTr("Could not detach utility. Error code: %1"),

                'detachSuccess': qsTr("Detached"),
            }
            setHandler('error', function(name, info, other) {
                if (name in errorStrings) var text = errorStrings[name]
                else {
                    // generally should not happen unless I forget to put an error
                    shared.showError(qsTranslate("Errors", "Unknown error: %1").arg(name), info + ': ' + other)
                    return
                }

                switch(name) {
                case 'configLoadJSON':
                case 'configLoadPermissions':
                case 'configSavePermissions':
                case 'detachError':
                    shared.showError(text.arg(info))
                    break
                case 'configSaveNotFound':
                    shared.showError(text.arg(info), qsTranslate("Errors", "This usually means that configuration directory could not be created", "Description for 'Unable to save config %1: file not found'"))
                    break
                case 'configDirPermissions':
                    shared.showError(text.arg(info), other)
                    break
                default:
                    shared.showError(text, info)
                }
            })
            setHandler('detachSuccess', function() { shared.showInfo(qsTr("Detached")) })

            addImportPath(Qt.resolvedUrl('../lib/deps'))
            addImportPath(Qt.resolvedUrl('../python'))
            importModule('main', function() {
                reloadConstants(function() {
                    initialized=true
                    reposModel.init()
                })
            })
        }

        function reloadConstants(callback) {
            call2('set_constants', [StandardPaths.data, StandardPaths.cache, config.cachePeriod], callback)
        }
    }

    ListModel {
        id: reposModel
        property bool loaded

        function init() {
            py.setHandler('reposLoaded', function(state) { loaded = state })
            py.setHandler('repo', append)
            py.setHandler('repoRemove', function(hash) {
                var i = findIndexByUrlHash(hash)
                if (i !== -1) remove(i)
            })
            py.setHandler('repoUpdate', function(hash, repo) {
                var i = findIndexByUrlHash(hash)
                if (i !== -1) set(i, repo)
                else append(repo)
            })
            py.call2('request_repos')
        }

        function findIndexByUrlHash(hash) {
            for(var i=0; i < count; i++)
                if (get(i).hash === hash) return i
            return -1
        }

        function findIndexByUrl(url) {
            for(var i=0; i < count; i++)
                if (get(i).url === url) return i
            return -1
        }
    }
}
