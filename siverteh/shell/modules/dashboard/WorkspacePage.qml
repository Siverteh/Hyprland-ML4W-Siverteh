import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/utils"
import Quickshell
import QtQuick
Column {
    id:root
    required property PersistentProperties visibilities
    spacing:Appearance.spacing.normal
    function appName(c) {
        if(c.wmClass==="siverteh-ai-task")return "AI chat";
        if(c.wmClass==="siverteh-ai-dashboard")return "Siverteh AI";
        if(c.wmClass.startsWith("chrome-mail."))return "Mail";
        if(c.wmClass.startsWith("chrome-127."))return "Brain";
        return Icons.getDesktopEntry(c.wmClass)?.name??c.wmClass;
    }
    StyledText {text:"Workspaces";font.pointSize:Appearance.font.size.large}
    Grid {columns:4;spacing:12
        Repeater {model:7
            StyledRect {
                id:card
                required property int index
                readonly property int ws:index+1
                readonly property var windows:Hyprland.clients.filter(c=>c.workspace?.id===ws)
                implicitWidth:190;implicitHeight:135;radius:Appearance.rounding.normal
                color:Hyprland.activeWsId===ws?Colours.palette.m3primaryContainer:Colours.palette.m3surfaceContainer
                Column {anchors.fill:parent;anchors.margins:15;spacing:10
                    Row {spacing:8
                        MaterialIcon {text:BarConfig.workspaceIcons[card.index]}
                        StyledText {text:card.ws+"  "+BarConfig.workspaceNames[card.index];font.weight:500}
                    }
                    StyledText {width:160;elide:Text.ElideRight;text:card.windows.length?card.windows.slice(0,3).map(c=>root.appName(c)).join("\n"):"Empty";color:Colours.palette.m3onSurfaceVariant}
                    StyledText {text:card.windows.length+(card.windows.length===1?" window":" windows");font.pointSize:10;color:Colours.palette.m3outline}
                }
                MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:{root.visibilities.dashboard=false;Hyprland.dispatch("workspace "+card.ws)}}
            }
        }
    }
}
