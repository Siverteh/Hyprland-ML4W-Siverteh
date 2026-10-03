pragma ComponentBehavior: Bound
import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/modules/bar/components" as Native
import "root:/modules/bar/components/workspaces" as NativeWs
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Variants {
    model: Quickshell.screens
    StyledWindow {
        id: win
        required property ShellScreen modelData
        screen: modelData
        name: "topbar"
        anchors.top: true; anchors.left: true; anchors.right: true
        implicitHeight: 40
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        color: Colours.palette.m3surface
        readonly property var visibility: Visibilities.screens[screen.name]
        RowLayout {
            anchors.fill:parent; anchors.leftMargin:Appearance.padding.large; anchors.rightMargin:Appearance.padding.large
            spacing:Appearance.spacing.normal
            Native.OsIcon {
                text:"󰣇"
                MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:win.visibility.launcher=!win.visibility.launcher }
            }
            StyledRect {
                radius:Appearance.rounding.full
                color:Colours.palette.m3surfaceContainer
                implicitHeight:34
                implicitWidth:workspaces.implicitHeight+Appearance.padding.small*2
                NativeWs.Workspaces {
                    id:workspaces
                    anchors.centerIn:parent
                    rotation:-90
                    horizontal:true
                }
            }
            Item {
                Layout.fillWidth:true
                Layout.preferredHeight:30
                Native.ActiveWindow {
                    id:active
                    anchors.centerIn:parent
                    width:30; height:parent.width
                    rotation:90
                    monitor:Brightness.getMonitorForScreen(win.screen)
                }
            }
            Item {
                implicitWidth:tray.implicitHeight; implicitHeight:tray.implicitWidth
                Native.Tray { id:tray; anchors.centerIn:parent; rotation:-90 }
            }
            MaterialIcon { text:"calendar_month"; color:Colours.palette.m3tertiary }
            StyledText { text:Time.format("HH:mm"); color:Colours.palette.m3tertiary }
            StyledRect {
                radius:Appearance.rounding.full
                color:Colours.palette.m3surfaceContainer
                implicitWidth:status.implicitHeight+Appearance.padding.small*2
                implicitHeight:34
                Native.StatusIcons { id:status; anchors.centerIn:parent; rotation:-90; horizontal:true }
                MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked: {
                    const ratio=mouseX/width;
                    Quickshell.execDetached(["siverteh-os-shell",ratio<0.34?"wifi":ratio<0.67?"bluetooth":"toggle"]);
                } }
            }
            Native.Power {}
        }
        MouseArea {
            anchors.horizontalCenter:parent.horizontalCenter
            width:Math.min(700,parent.width*0.45); height:40
            hoverEnabled:true
            acceptedButtons:Qt.NoButton
            onEntered: if(win.visibility)win.visibility.dashboard=true
            onExited: if(win.visibility&&mouseY<height-2)win.visibility.dashboard=false
        }
    }
}
