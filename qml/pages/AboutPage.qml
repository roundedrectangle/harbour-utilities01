import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.About 1.0

AboutPageBase {
    allowedOrientations: defaultAllowedOrientations
    property bool __utilities_page

    appName: qsTr("Utilities")
    appVersion: "Alpha 1"
    appRelease: "1"
    description: qsTr("Simple utilities")
    sourcesUrl: "https://github.com/roundedrectangle/harbour-utilities01"
    appIcon: Qt.resolvedUrl("../../images/harbour-utilities01.png")

    _iconItem.width: Math.min(2 * Theme.itemSizeHuge, Math.min(page.width, page.height) / 2)
    _iconItem.height: _iconItem.width
    _iconItem.sourceSize.width: _iconItem.width
    _iconItem.sourceSize.height: _iconItem.height

    authors: "roundedrectangle"
    licenses: License { spdxId: "GPL-3.0-or-later" }

    autoAddOpalAttributions: true
    contributionSections: [
        ContributionSection {
            title: qsTr("Translations")
            groups: [
                ContributionGroup {
                    title: qsTr("Italian")
                    entries: "247"
                }
            ]
        }
    ]
}
