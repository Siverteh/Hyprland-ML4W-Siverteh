import "root:/services"
import "root:/widgets"
import Quickshell
import Quickshell.Wayland
import QtQuick
Variants {
    model:Quickshell.screens
    StyledWindow {
        id:win;required property ShellScreen modelData;screen:modelData;name:"brain-edge"
        readonly property var visibility:Visibilities.screens[screen.name]
        visible:DesktopSettings.data.leftDrawer!==false&&!Visibilities.hidden&&!!visibility&&!visibility.session&&!visibility.launcher&&!visibility.left
        WlrLayershell.exclusionMode:ExclusionMode.Ignore;WlrLayershell.layer:WlrLayer.Top
        anchors.left:true;implicitWidth:6;implicitHeight:200
        MouseArea {id:hover;anchors.fill:parent;hoverEnabled:true
            onEntered:delay.restart()
            onExited:delay.stop()
            Timer {id:delay;interval:250;onTriggered:{win.visibility.dashboard=false;win.visibility.left=true;}}
        }
    }
}
