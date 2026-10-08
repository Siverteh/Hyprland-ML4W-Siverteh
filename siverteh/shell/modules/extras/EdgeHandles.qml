import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.widgets

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData
        readonly property var visibility: Visibilities.screens[modelData.name]
        readonly property bool available: DesktopSettings.data.clickEdgeMenus === true && !Visibilities.hidden && !!visibility && !visibility.launcher && !visibility.session && visibility.edgeMenu === "" && !visibility.dashboardPinned

        StyledWindow {
            id: left

            name: "left-menu-handle"
            screen: scope.modelData
            visible: scope.available && DesktopSettings.data.leftDrawer !== false && !scope.visibility.left
            anchors.left: true
            implicitWidth: 46
            implicitHeight: 48
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.layer: WlrLayer.Overlay

            EdgeMenuHandle {
                id: leftHandle

                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                icon: "chevron_right"
                onClicked: Visibilities.openEdge("left", scope.modelData.name)
            }

            mask: Region {
                x: 0
                width: leftHandle.shown ? left.width : 6
                height: left.height
            }

        }

        StyledWindow {
            id: right

            name: "right-menu-handle"
            screen: scope.modelData
            visible: scope.available && DesktopSettings.data.rightEdge !== false && !scope.visibility.osd
            anchors.right: true
            implicitWidth: 46
            implicitHeight: 48
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.layer: WlrLayer.Overlay

            EdgeMenuHandle {
                id: rightHandle

                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                icon: "tune"
                onClicked: Visibilities.openEdge("osd", scope.modelData.name)
            }

            mask: Region {
                x: rightHandle.shown ? 0 : right.width - 6
                width: rightHandle.shown ? right.width : 6
                height: right.height
            }

        }

    }

}
