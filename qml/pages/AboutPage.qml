import QtQuick 2.0
import Sailfish.Silica 1.0
import Opal.About 1.0

AboutPageBase {
    appName: qsTr("Utilities")
    appVersion: "Alpha 1"
    appRelease: "1"
    description: qsTr("Simple utilities")
    sourcesUrl: "https://github.com/roundedrectangle/harbour-utilities01"

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
