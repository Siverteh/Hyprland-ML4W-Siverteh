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
    function refresh() {
        if (!reader.running)
            reader.running = true;
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
    Component.onCompleted: refresh()
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
    Timer {
        id: delay
        interval: 80
        onTriggered: root.write()
    }
    Process {
        id: reader
        command: ["python3", "-c", "import json;from pathlib import Path;p=next((p for p in Path('/sys/class/leds').glob('*kbd_backlight*') if (p/'max_brightness').exists()),None);print(json.dumps(dict(device=p.name,maximum=int((p/'max_brightness').read_text()),current=int((p/'brightness').read_text())) if p else {}))"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    const s = JSON.parse(line);
                    root.device = s.device ?? "";
                    root.maximum = s.maximum ?? 0;
                    if (!writer.running && root.pending < 0)
                        root.brightness = root.maximum ? (s.current / root.maximum) : 0;
                } catch (e) {
                    root.device = "";
                }
            }
        }
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
