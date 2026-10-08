import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.services
import qs.widgets

Variants {
    model: DisplayRecovery.surfaceScreens

    StyledWindow {
        id: win

        required property ShellScreen modelData
        readonly property var visibility: Visibilities.screens[screen.name]

        screen: modelData
        name: "brain-edge"
        visible: DesktopSettings.data.clickEdgeMenus === false && DesktopSettings.data.leftDrawer !== false && !Visibilities.hidden && !!visibility && !visibility.session && !visibility.launcher && !visibility.left && !HoverIntent.fullscreenFor(screen.name)
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        anchors.left: true
        implicitWidth: HoverIntent.edgeWidth
        implicitHeight: Math.min(810, screen.height - 150)
        margins.top: BorderConfig.headerHeight
        margins.bottom: BorderConfig.bottom

        IpcHandler {
            function state(): string {
                return JSON.stringify({
                    "registered": !!win.visibility,
                    "visible": win.visible,
                    "width": win.width,
                    "height": win.height
                });
            }

            target: "leftEdge"
        }

        MouseArea {
            id: hover

            function enter(buttons) {
                const point = mapToGlobal(mouseX, mouseY);
                HoverIntent.observe(win.screen, point.x - win.screen.x, point.y - win.screen.y);
                if (HoverIntent.canOpen("left", win.screen, buttons)) {
                    win.visibility.dashboard = false;
                    win.visibility.left = true;
                }
            }

            anchors.fill: parent
            hoverEnabled: true
            onEntered: enter(pressedButtons)
            onPositionChanged: event => {
                return enter(event.buttons);
            }
            onExited: {
                if (!win.visibility.left)
                    HoverIntent.rearm("left", win.screen);
            }
        }
    }
}
