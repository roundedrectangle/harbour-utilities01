import QtQuick 2.0

QtObject {
    id: pageStack
    property int depth

    property bool acceptAnimationRunning: window.pageStack.acceptAnimationRunning
    property bool busy: window.pageStack.busy
    property Component pageBackground: window.pageStack.pageBackground

    function push(page, properties, operationType) { window.pageStack.push(page, properties, operationType) }
    function pushAttached(page, properties, operationType) { window.pageStack.pushAttached(page, properties, operationType) }
    function completeAnimation() { window.pageStack.completeAnimation() }


    property Item currentPage: window.pageStack.currentPage.__utilities_page === 'undefined' ? window.pageStack.currentPage : null

    function find(func) {
        return window.pageStack.find(function(page) { return typeof page.__utilities_page === 'undefined' && func(page) })
    }
    function clear(func) {
        if (window.pageStack.currentPage.__utilities_page === 'undefined')
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
        if (window.pageStack.currentPage.__utilities_page === 'undefined')
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
