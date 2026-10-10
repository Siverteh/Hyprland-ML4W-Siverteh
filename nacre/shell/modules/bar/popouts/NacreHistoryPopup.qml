import QtQuick
import qs.widgets
import qs.services
import qs.modules.notifications

Item {
    id: root
    readonly property var entries: NacreNotifs.retained
    implicitWidth: 380
    implicitHeight: body.implicitHeight
    function clear() {
        if (entries.length)
            NacreNotifs.clearHistory();
    }
    Column {
        id: body
        width: root.width
        spacing: 12
        Row {
            width: parent.width
            spacing: 10
            NacreText {
                width: parent.width - 84
                anchors.verticalCenter: parent.verticalCenter
                text: "Notifications"
                font.pointSize: 14
            }
            ActionButton {
                objectName: "quickClearHistory"
                text: "Clear"
                compact: true
                enabled: root.entries.length > 0
                onClicked: root.clear()
            }
        }
        ActionButton {
            objectName: "quickDnd"
            text: NacreNotifs.dnd ? "Do not disturb: On" : "Do not disturb: Off"
            selected: NacreNotifs.dnd
            onClicked: DesktopSettings.set("dnd", !NacreNotifs.dnd)
        }
        NacreText {
            width: parent.width
            visible: root.entries.length === 0
            text: NacreNotifs.historyReady ? "No notifications" : "Loading notifications…"
            color: NacreTokens.mutedInk
        }
        NacreQuickList {
            width: parent.width
            maximumHeight: 440
            Column {
                width: parent.width
                spacing: 8
                Repeater {
                    model: root.entries
                    delegate: NacreNotice {
                        width: parent.width - 10
                        history: true
                    }
                }
            }
        }
    }
}
