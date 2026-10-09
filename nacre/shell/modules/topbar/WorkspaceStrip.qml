import qs.widgets
import qs.services
import qs.config
import QtQuick

Row {
    spacing: 3
    Repeater {
        model: 7
        NacreSurface {
            id: button
            required property int index
            readonly property int ws: index + 1
            readonly property bool selected: NacreHyprland.activeWsId === ws
            readonly property bool occupied: NacreHyprland.clients.some(c => c.workspace?.id === ws)
            implicitWidth: 46
            implicitHeight: 30
            radius: 15
            color: selected ? NacreColours.palette.m3primary : "transparent"
            Row {
                anchors.centerIn: parent
                spacing: 4
                NacreIcon {
                    text: NacreBar.workspaceIcons[button.index]
                    font.pointSize: 12
                    color: button.selected ? NacreColours.palette.m3onPrimary : NacreColours.palette.m3onSurfaceVariant
                }
                NacreText {
                    text: button.ws
                    font.pointSize: 10
                    color: button.selected ? NacreColours.palette.m3onPrimary : NacreColours.palette.m3onSurfaceVariant
                }
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2
                anchors.horizontalCenter: parent.horizontalCenter
                width: 3
                height: 3
                radius: 2
                visible: button.occupied
                color: button.selected ? NacreColours.palette.m3onPrimary : NacreColours.palette.m3primary
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: NacreHyprland.dispatch("workspace " + button.ws)
            }
        }
    }
}
