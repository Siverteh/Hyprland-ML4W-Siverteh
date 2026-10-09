pragma Singleton
import Quickshell

Singleton {
    readonly property string device: NacreKeyboardLight.device
    readonly property int maximum: NacreKeyboardLight.maximum
    readonly property real brightness: NacreKeyboardLight.brightness
    readonly property bool available: NacreKeyboardLight.available
    readonly property string error: NacreKeyboardLight.error
    function refresh() {
        NacreKeyboardLight.refresh();
    }
    function readNative() {
        NacreKeyboardLight.readNative();
    }
    function setBrightness(value) {
        return NacreKeyboardLight.setBrightness(value);
    }
}
