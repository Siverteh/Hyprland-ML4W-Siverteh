import qs.widgets
import qs.services
import qs.config
import qs.modules.notifications as Cards
import Quickshell
import QtQuick

Column {
    width: 400
    spacing: 12
    Row {
        width: 400
        spacing: 12
        NacreText {
            width: 310
            text: "Notifications · " + NacreNotifs.retained.length
            font.weight: 500
        }
        NacreSurface {
            implicitWidth: 78
            implicitHeight: 30
            radius: 15
            color: Colours.palette.m3surfaceContainer
            NacreText {
                anchors.centerIn: parent
                text: "Clear all"
                font.pointSize: 10
            }
            NacreInteraction {
                disabled: NacreNotifs.retained.length === 0
                function onClicked() {
                    NacreNotifs.clearHistory();
                }
            }
        }
    }
    Item {
        width: 400
        height: 320
        NacreText {
            anchors.centerIn: parent
            text: "No notifications"
            visible: NacreNotifs.retained.length === 0
            color: Colours.palette.m3onSurfaceVariant
        }
        ListView {
            id: historyList
            anchors.fill: parent
            clip: true
            spacing: 8
            FastScroll {
                view: historyList
            }
            model: ScriptModel {
                values: [...NacreNotifs.retained].reverse()
            }
            delegate: Cards.NacreNotice {
                history: true
                width: historyList.width
            }
        }
    }
}
