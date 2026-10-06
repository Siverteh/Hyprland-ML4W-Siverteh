pragma Singleton
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property string icon: ""
    property string description: ""
    property real temperature: 0
    property string location: ""
    property string error: ""
    property bool stale: false
    readonly property string displayTemperature: description ? (DesktopSettings.data.weatherFahrenheit ? Math.round(temperature * 9 / 5 + 32) + "°F" : Math.round(temperature) + "°C") + (stale ? " (cached)" : "") : ""
    function reload() {
        if (!worker.running)
            worker.running = true;
    }
    Connections {
        target: DesktopSettings
        function onDataChanged() {
            if (root.lastLocation !== (DesktopSettings.data.weatherLocation ?? "")) {
                root.lastLocation = DesktopSettings.data.weatherLocation ?? "";
                root.reload();
            }
        }
    }
    property string lastLocation: ""
    Timer {
        interval: 1800000
        repeat: true
        running: true
        onTriggered: root.reload()
    }
    Process {
        id: worker
        running: true
        command: ["python3", Quickshell.env("HOME") + "/.local/share/siverteh-ai/siverteh-shell/tools/weather.py"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: line => {
                try {
                    const data = JSON.parse(line);
                    root.icon = data.code ? Icons.getWeatherIcon(data.code) : "cloud_off";
                    root.description = data.description ?? "";
                    root.temperature = data.temperature ?? 0;
                    root.location = data.location ?? "";
                    root.stale = data.stale ?? false;
                    root.error = data.error ?? "";
                } catch (e) {
                    root.error = "Could not read weather";
                }
            }
        }
    }
}
