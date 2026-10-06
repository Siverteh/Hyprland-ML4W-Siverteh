import qs.services
import qs.widgets
import qs.config
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
Variants {
    model:Quickshell.screens
    StyledWindow {
        id:win;required property ShellScreen modelData;screen:modelData;name:"brain-edge"
        readonly property var visibility:Visibilities.screens[screen.name]
        visible:DesktopSettings.data.leftDrawer!==false&&!Visibilities.hidden&&!!visibility&&!visibility.session&&!visibility.launcher&&!visibility.left
        WlrLayershell.exclusionMode:ExclusionMode.Ignore;WlrLayershell.layer:WlrLayer.Top
        anchors.left:true;implicitWidth:6;implicitHeight:Math.min(810,screen.height-150)
        margins.top:BorderConfig.headerHeight;margins.bottom:BorderConfig.bottom
        IpcHandler {target:"leftEdge";function state():string{return JSON.stringify({registered:!!win.visibility,visible:win.visible,width:win.width,height:win.height});}}
        MouseArea {id:hover;anchors.fill:parent;hoverEnabled:true
            onEntered:delay.restart()
            onExited:delay.stop()
            Timer {id:delay;interval:100;onTriggered:{win.visibility.dashboard=false;win.visibility.left=true;}}
        }
    }
}
