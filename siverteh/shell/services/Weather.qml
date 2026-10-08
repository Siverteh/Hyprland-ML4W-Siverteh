pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    property string icon: ""
    property string description: ""
    property real temperature: 0
    property var feelsLike: null
    property var high: null
    property var low: null
    function degrees(value) {
        if (value === null || value === undefined)
            return "";
        return Math.round(DesktopSettings.data.weatherFahrenheit ? value * 9 / 5 + 32 : value) + "°" + (DesktopSettings.data.weatherFahrenheit ? "F" : "C");
    }
    readonly property string detail: (feelsLike !== null ? "Feels like " + degrees(feelsLike) : "")
    readonly property string range: high !== null && low !== null ? "High " + degrees(high) + " · Low " + degrees(low) : ""
    property string location: ""
    property string error: ""
    property bool stale: false
    readonly property string displayTemperature: description ? (DesktopSettings.data.weatherFahrenheit ? Math.round(temperature * 9 / 5 + 32) + "°F" : Math.round(temperature) + "°C") + (stale ? " (cached)" : "") : ""
    property string lastLocation: ""

    function reload() {
        if (!worker.running)
            worker.running = true;
    }

    Connections {
        function onDataChanged() {
            if (root.lastLocation !== (DesktopSettings.data.weatherLocation ?? "")) {
                root.lastLocation = DesktopSettings.data.weatherLocation ?? "";
                root.reload();
            }
        }

        target: DesktopSettings
    }

    Timer {
        interval: 1.8e+06
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
                    root.feelsLike = data.feelsLike ?? null;
                    root.high = data.high ?? null;
                    root.low = data.low ?? null;
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
