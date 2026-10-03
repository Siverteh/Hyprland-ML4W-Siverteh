pragma ComponentBehavior: Bound
import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/modules/bar/components" as Native
import "root:/modules/bar/components/workspaces" as NativeWs
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Variants {
    model: Quickshell.screens
    StyledWindow {
        id: win
        required property ShellScreen modelData
        screen: modelData
        name: "topbar"
        contentItem.opacity: Visibilities.reveal
        mask: Region { width: Visibilities.hidden ? 0 : win.width; height: win.height }
        anchors.top:true; anchors.left:true; anchors.right:true
        implicitHeight:BorderConfig.headerHeight
        WlrLayershell.exclusionMode:ExclusionMode.Ignore
        WlrLayershell.layer:WlrLayer.Top
        color:"transparent"
        Rectangle { anchors.fill:parent; color:Colours.palette.m3surface }
        readonly property var visibility:Visibilities.screens[screen.name]
        Process { id: connectionManager }
        Timer {
            id: dismissPopout
            interval:120
            onTriggered: {
                const p=Visibilities.panels[win.screen.name];
                if(p && !p.parent.containsMouse) p.popouts.hasCurrent=false;
            }
        }
        function openConnections(name,item) {
            if(name === "battery") { hoverMenu(name,item); return; }
            const p=Visibilities.panels[screen.name];if(p)p.popouts.hasCurrent=false;
            connectionManager.command=["siverteh-os-shell",name === "network" ? "wifi" : "bluetooth"];
            connectionManager.startDetached();
        }
        function hoverMenu(name,item){dismissPopout.stop();const p=item.mapToItem(win.contentItem,item.width/2,0);Visibilities.popout(name,p.x,screen.name);}
        RowLayout {
            id:leftGroup
            anchors.left:parent.left;anchors.leftMargin:Appearance.padding.large;anchors.verticalCenter:parent.verticalCenter
            spacing:Appearance.spacing.normal
            Native.OsIcon { text:"󰣇";MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:{win.visibility.launcherMode="apps";win.visibility.launcherQuery="";win.visibility.launcherRequest++;win.visibility.launcher=!win.visibility.launcher;} } }
            StyledRect {
                radius:Appearance.rounding.full;color:Colours.palette.m3surfaceContainer
                implicitHeight:34;implicitWidth:workspaces.implicitHeight+Appearance.padding.small*2
                NativeWs.Workspaces {id:workspaces;anchors.centerIn:parent;rotation:-90;horizontal:true}
            }
        }
        Native.ActiveWindow {
            anchors.horizontalCenter:parent.horizontalCenter;anchors.verticalCenter:parent.verticalCenter
            width:Math.max(100,Math.min(650,win.width-2*Math.max(leftGroup.width,rightGroup.width)-50));height:30
            horizontal:true;monitor:Brightness.getMonitorForScreen(win.screen)
        }
        RowLayout {
            id:rightGroup
            anchors.right:parent.right;anchors.rightMargin:Appearance.padding.large;anchors.verticalCenter:parent.verticalCenter
            spacing:Appearance.spacing.normal
            Item {implicitWidth:tray.implicitHeight;implicitHeight:tray.implicitWidth;Native.Tray {id:tray;anchors.centerIn:parent;rotation:-90}}
            Item {
                implicitWidth:clockRow.implicitWidth;implicitHeight:34
                Row { id:clockRow;anchors.centerIn:parent;spacing:Appearance.spacing.small
                    MaterialIcon {text:"calendar_month";color:Colours.palette.m3tertiary}
                    StyledText {text:Time.format("HH:mm");color:Colours.palette.m3tertiary}
                }
                MouseArea { anchors.fill:parent;hoverEnabled:true;cursorShape:Qt.PointingHandCursor
                    onEntered:win.hoverMenu("calendar",this)
                    onExited:dismissPopout.restart()
                    onClicked:win.hoverMenu("calendar",this)
                }
            }
            StyledRect {
                radius:Appearance.rounding.full;color:Colours.palette.m3surfaceContainer
                implicitWidth:status.implicitHeight+Appearance.padding.small*2;implicitHeight:34
                Native.StatusIcons {id:status;anchors.centerIn:parent;rotation:-90;horizontal:true}
                Row {
                    anchors.fill:parent
                    Repeater {model:["network","bluetooth","battery"]
                        MouseArea {
                            required property string modelData
                            width:parent.width/3;height:parent.height;hoverEnabled:true;cursorShape:Qt.PointingHandCursor
                            onEntered:win.hoverMenu(modelData,this)
                            onExited:dismissPopout.restart()
                            onClicked:win.openConnections(modelData,this)
                        }
                    }
                }
            }
            Native.Power {}
        }
        MouseArea {
            anchors.horizontalCenter:parent.horizontalCenter;width:Math.min(700,parent.width*0.45);height:win.height
            hoverEnabled:true;acceptedButtons:Qt.NoButton
            onEntered:if(win.visibility&&!win.visibility.session){const p=Visibilities.panels[win.screen.name];if(p)p.popouts.hasCurrent=false;win.visibility.dashboard=true;}
            onExited:if(win.visibility&&mouseY<height-2)win.visibility.dashboard=false
        }
    }
}
