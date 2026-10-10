pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property var data: ({})
    property var monitors: []
    property bool pending: false
    property string message: ""
    property var queue: []
    readonly property bool busy: worker.running
    function request(args) {
        queue.push(args);
        next();
    }
    function next() {
        if (!worker.running && queue.length) {
            worker.command = ["python3", Quickshell.env("HOME") + "/.local/share/nacre/shell/tools/desktop-settings.py", ...queue.shift()];
            worker.running = true;
        }
    }
    function set(key, value) {
        request(["set", key, JSON.stringify(value)]);
    }
    function refresh() {
        if (!busy && queue.length === 0)
            request(["state"]);
    }
    Component.onCompleted: request(["state"])
    FileView {
        path: Quickshell.env("HOME") + "/.config/nacre/desktop.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.data = JSON.parse(text());
            } catch (e) {}
        }
    }
    readonly property bool visibleSettings: NacrePanelState.settingsVisible
    onVisibleSettingsChanged: if (visibleSettings)
        refresh()
    Timer {
        interval: visibleSettings ? 3000 : 60000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }
    Process {
        id: worker
        stdout: SplitParser {
            splitMarker: ""
            onRead: line => {
                try {
                    const result = JSON.parse(line);
                    root.data = result.data;
                    root.monitors = result.monitors ?? root.monitors;
                    root.pending = result.pending;
                    root.message = result.error ?? result.message;
                } catch (e) {
                    root.message = "Could not read desktop settings";
                }
            }
        }
        onExited: root.next()
    }
    IpcHandler {
        target: "desktopSettings"
        function state(): string {
            return JSON.stringify({
                data: root.data,
                monitors: root.monitors,
                pending: root.pending,
                message: root.message,
                busy: root.busy
            });
        }
        function set(key: string, value: string): void {
            root.set(key, JSON.parse(value));
        }
    }
}
