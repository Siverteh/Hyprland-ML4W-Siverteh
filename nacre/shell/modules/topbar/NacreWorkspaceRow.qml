import QtQuick
import qs.widgets
import qs.services
import qs.config

Row {
    id: root
    spacing: 3
    function activate(id) {
        if (Number.isInteger(id) && id >= 1 && id <= 7)
            return NacreHyprland.dispatch("workspace " + id);
        return false;
    }
    Repeater {
        model: 7
        delegate: NacreSurface {
            id: pill
            required property int index
            readonly property int workspaceId: index + 1
            readonly property bool selected: NacreHyprland.activeWsId === workspaceId
            readonly property bool occupied: NacreHyprland.clients.some(client => client.workspace?.id === workspaceId)
            objectName: "nacreWorkspace" + workspaceId
            implicitWidth: 46
            implicitHeight: 30
            radius: 15
            color: selected ? NacreColours.palette.m3primary : "transparent"
            Row {
                anchors.centerIn: parent
                spacing: 4
                NacreIcon {
                    text: NacreBar.workspaceIcons[pill.index] || "apps"
                    font.pointSize: 11
                    color: pill.selected ? NacreColours.palette.m3onPrimary : NacreColours.palette.m3onSurfaceVariant
                }
                NacreText {
                    text: pill.workspaceId
                    font.pointSize: 10
                    color: pill.selected ? NacreColours.palette.m3onPrimary : NacreColours.palette.m3onSurfaceVariant
                }
            }
            Rectangle {
                width: 3
                height: 3
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2
                visible: pill.occupied
                color: pill.selected ? NacreColours.palette.m3onPrimary : NacreColours.palette.m3primary
            }
            NacreInteraction {
                accessibleName: "Workspace " + pill.workspaceId + ": " + (NacreBar.workspaceNames[pill.index] || "")
                function onClicked() {
                    root.activate(pill.workspaceId);
                }
            }
        }
    }
}
