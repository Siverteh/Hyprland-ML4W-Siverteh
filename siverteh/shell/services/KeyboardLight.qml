pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property string device: ""
    property int maximum: 0
    property real brightness: 0
    property int pending: -1
    property string error: ""
    readonly property bool available: device.length > 0 && maximum > 0
    readonly property bool controlsVisible: Object.values(Visibilities.screens).some(v => v.dashboard || v.osd)
    onControlsVisibleChanged: if (controlsVisible)
        refresh()
    function refresh() {
        maximumFile.reload();
        currentFile.reload();
    }
    function readNative() {
        maximum = parseInt(maximumFile.text()) || 0;
        if (!writer.running && pending < 0)
            brightness = maximum ? (parseInt(currentFile.text()) || 0) / maximum : 0;
    }
    function setBrightness(value) {
        if (!available)
            return;
        pending = Math.round(Math.max(0, Math.min(1, value)) * maximum);
        brightness = pending / maximum;
        delay.restart();
    }
    function write() {
        if (writer.running || pending < 0)
            return;
        writer.command = ["brightnessctl", "-c", "leds", "-d", device, "set", String(pending)];
        pending = -1;
        writer.running = true;
    }

    Timer {
        interval: 5000
        running: root.controlsVisible
        repeat: true
        onTriggered: root.refresh()
    }
    Timer {
        id: delay
        interval: 80
        onTriggered: root.write()
    }
    Process {
        running: true
        command: ["brightnessctl", "-c", "leds", "-m"]
        stdout: SplitParser {
            onRead: line => {
                const device = line.split(",")[0];
                if (/kbd.*backlight/i.test(device))
                    root.device = device;
            }
        }
    }
    FileView {
        id: maximumFile
        path: root.device ? "/sys/class/leds/" + root.device + "/max_brightness" : ""
        onLoaded: root.readNative()
    }
    FileView {
        id: currentFile
        path: root.device ? "/sys/class/leds/" + root.device + "/brightness" : ""
        onLoaded: root.readNative()
    }
    Process {
        id: writer
        onExited: code => {
            root.error = code === 0 ? "" : "Keyboard light could not be changed";
            root.refresh();
            delay.restart();
        }
    }
    IpcHandler {
        target: "keyboardLight"
        function step(direction: string): void {
            if (direction === "up")
                root.setBrightness(root.brightness + 0.1);
            else if (direction === "down")
                root.setBrightness(root.brightness - 0.1);
        }
        function state(): string {
            return JSON.stringify({
                available: root.available,
                device: root.device,
                maximum: root.maximum,
                value: root.brightness,
                error: root.error
            });
        }
        function set(value: real): void {
            root.setBrightness(value);
        }
    }
}
