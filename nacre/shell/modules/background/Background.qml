import Quickshell
import Quickshell.Wayland
import qs.widgets

Variants {
    model: Quickshell.screens

    NacreWindow {
        id: win

        required property ShellScreen modelData

        screen: modelData
        name: "background"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        color: "black"
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        Wallpaper {
            screenName: win.modelData.name
        }
    }
}
