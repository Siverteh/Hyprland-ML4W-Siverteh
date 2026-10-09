pragma Singleton
pragma ComponentBehavior: Bound

import qs.widgets
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var ddcMonitors: []
    property string backlightDevice: ""
    readonly property bool controlsVisible: Object.values(Visibilities.screens).some(v => v.dashboard || v.osd)
    onControlsVisibleChanged: if (controlsVisible)
        for (const m of monitors)
            if (!m.isDdc)
                m.refresh()
    Process {
        running: true
        command: ["brightnessctl", "-c", "backlight", "-m"]
        stdout: SplitParser {
            onRead: data => {
                root.backlightDevice = data.split(",")[0];
                for (const m of root.monitors)
                    m.refresh();
            }
        }
    }
    IpcHandler {
        target: "brightness"
        function state(): string {
            return JSON.stringify(root.monitors.map(m => ({
                        screen: m.modelData.name,
                        value: m.brightness,
                        device: root.backlightDevice,
                        available: m.available
                    })));
        }
        function step(direction: string): void {
            if (direction === "up")
                root.increaseBrightness();
            else if (direction === "down")
                root.decreaseBrightness();
        }
        function set(value: real): string {
            const m = root.monitors[0];
            if (m)
                m.setBrightness(value);
            return JSON.stringify({
                found: !!m,
                available: m?.available,
                requested: value,
                brightness: m?.brightness,
                command: m?.writer.command,
                running: m?.writer.running,
                pending: m?.pendingPercent
            });
        }
    }
    readonly property list<Monitor> monitors: variants.instances

    function getMonitorForScreen(screen: ShellScreen): var {
        return monitors.find(m => m.modelData.name === screen?.name);
    }

    function increaseBrightness(): void {
        const focusedName = Hyprland.focusedMonitor.name;
        const monitor = monitors.find(m => focusedName === m.modelData.name);
        if (monitor)
            monitor.setBrightness(monitor.brightness + 0.05);
    }

    function decreaseBrightness(): void {
        const focusedName = Hyprland.focusedMonitor.name;
        const monitor = monitors.find(m => focusedName === m.modelData.name);
        if (monitor)
            monitor.setBrightness(monitor.brightness - 0.05);
    }

    Timer {
        interval: 5000
        running: root.controlsVisible
        repeat: true
        onTriggered: {
            for (const m of root.monitors)
                if (!m.isDdc)
                    m.refresh();
        }
    }
    reloadableId: "brightness"

    onMonitorsChanged: {
        ddcMonitors = [];
        ddcProc.running = true;
    }

    Variants {
        id: variants

        model: Quickshell.screens

        Monitor {}
    }

    Process {
        id: ddcProc

        command: ["sh", "-c", "command -v ddcutil >/dev/null && ddcutil detect --brief"]
        stdout: SplitParser {
            splitMarker: "\n\n"
            onRead: data => {
                if (data.startsWith("Display ")) {
                    const lines = data.split("\n").map(l => l.trim());
                    root.ddcMonitors.push({
                        model: lines.find(l => l.startsWith("Monitor:")).split(":")[2],
                        busNum: lines.find(l => l.startsWith("I2C bus:")).split("/dev/i2c-")[1]
                    });
                }
            }
        }
        onExited: root.ddcMonitorsChanged()
    }

    NacreShortcut {
        name: "brightnessUp"
        onPressed: root.increaseBrightness()
    }

    NacreShortcut {
        name: "brightnessDown"
        onPressed: root.decreaseBrightness()
    }

    component Monitor: QtObject {
        id: monitor

        required property ShellScreen modelData
        readonly property bool isDdc: root.ddcMonitors.some(m => m.model === modelData.model)
        readonly property string busNum: root.ddcMonitors.find(m => m.model === modelData.model)?.busNum ?? ""
        property real brightness
        property int pendingPercent: -1
        readonly property bool available: isDdc || (root.backlightDevice.length > 0 && (/^(eDP|LVDS)/i.test(modelData.name) || Quickshell.screens.length === 1))
        readonly property Timer writeDelay: Timer {
            interval: 60
            onTriggered: monitor.startWrite()
        }
        readonly property Process writer: Process {
            property int percent
            onExited: code => {
                monitor.refresh();
                if (code !== 0)
                    console.warn("Brightness write failed", code);
                monitor.writeDelay.restart();
            }
        }
        function startWrite() {
            if (writer.running || pendingPercent < 0)
                return;
            writer.percent = pendingPercent;
            pendingPercent = -1;
            writer.command = isDdc ? ["ddcutil", "-b", busNum, "setvcp", "10", writer.percent] : ["brightnessctl", "-c", "backlight", "-d", root.backlightDevice, "set", writer.percent + "%"];
            writer.running = true;
        }
        function refresh() {
            if (!available)
                return;
            if (isDdc) {
                if (!initProc.running) {
                    initProc.command = ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"];
                    initProc.running = true;
                }
            } else {
                maximum.reload();
                current.reload();
            }
        }
        function readNative() {
            const max = parseInt(maximum.text());
            const value = parseInt(current.text());
            if (max > 0 && Number.isFinite(value) && !writer.running && pendingPercent < 0)
                brightness = value / max;
        }
        readonly property FileView maximum: FileView {
            path: root.backlightDevice && !monitor.isDdc ? "/sys/class/backlight/" + root.backlightDevice + "/max_brightness" : ""
            onLoaded: monitor.readNative()
        }
        readonly property FileView current: FileView {
            path: root.backlightDevice && !monitor.isDdc ? "/sys/class/backlight/" + root.backlightDevice + "/brightness" : ""
            onLoaded: monitor.readNative()
        }

        readonly property Process initProc: Process {
            stdout: SplitParser {
                onRead: data => {
                    const [, , , current, max] = data.split(" ");
                    if (!monitor.writer.running && monitor.pendingPercent < 0)
                        monitor.brightness = parseInt(current) / parseInt(max);
                }
            }
        }

        function setBrightness(value: real): void {
            if (!available)
                return;
            value = Math.max(.01, Math.min(1, value));
            const percent = Math.round(value * 100);

            brightness = value;
            pendingPercent = percent;
            writeDelay.restart();
        }
        onBusNumChanged: refresh()
        Component.onCompleted: refresh()
    }
}
