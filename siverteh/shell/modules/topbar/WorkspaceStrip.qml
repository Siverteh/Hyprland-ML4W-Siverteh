import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick
Row {
    spacing:3
    Repeater {model:7
        StyledRect {
            id:button
            required property int index
            readonly property int ws:index+1
            readonly property bool selected:Hyprland.activeWsId===ws
            readonly property bool occupied:Hyprland.clients.some(c=>c.workspace?.id===ws)
            implicitWidth:46;implicitHeight:30;radius:15
            color:selected?Colours.palette.m3primary:"transparent"
            Row {anchors.centerIn:parent;spacing:4
                MaterialIcon {text:BarConfig.workspaceIcons[button.index];font.pointSize:12;color:button.selected?Colours.palette.m3onPrimary:Colours.palette.m3onSurfaceVariant}
                StyledText {text:button.ws;font.pointSize:10;color:button.selected?Colours.palette.m3onPrimary:Colours.palette.m3onSurfaceVariant}
            }
            Rectangle {anchors.bottom:parent.bottom;anchors.bottomMargin:2;anchors.horizontalCenter:parent.horizontalCenter;width:3;height:3;radius:2;visible:button.occupied;color:button.selected?Colours.palette.m3onPrimary:Colours.palette.m3primary}
            MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:Hyprland.dispatch("workspace "+button.ws)}
        }
    }
}
