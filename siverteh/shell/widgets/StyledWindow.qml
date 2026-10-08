import Quickshell
import Quickshell.Wayland
import qs.config
import qs.utils

PanelWindow {
    required property string name

    WlrLayershell.namespace: `caelestia-${name}`
    color: "transparent"
}
