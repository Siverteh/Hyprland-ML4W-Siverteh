import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.widgets
import qs.services
import qs.config

Variants {
    model: DisplayRecovery.surfaceScreens
    NacreWindow {
        id: surface
        required property var modelData
        screen: modelData
        name: "topbar"
        WlrLayershell.layer: NacrePanelState.panels[surface.screen?.name]?.input?.modal ? WlrLayer.Overlay : WlrLayer.Top
        visible: DesktopSettings.data.topEdge !== false
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: NacreFrame.headerHeight
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        mask: Region {
            width: NacrePanelState.hidden ? 0 : surface.width
            height: surface.height
        }
        NacreHeader {
            anchors.fill: parent
            screen: surface.screen
            opacity: NacrePanelState.reveal
        }
    }
}
