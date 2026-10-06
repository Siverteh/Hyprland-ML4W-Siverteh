pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property int count: 0

    function refresh() {
        if (!check.running)
            check.running = true;
    }

    Process {
        id: check
        command: ["python3", Quickshell.env("HOME") + "/.local/share/siverteh-ai/siverteh-shell/tools/updates.py"]
        running: true
    }
    Timer {
        interval: 1800000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }
    FileView {
        path: Quickshell.env("HOME") + "/.cache/siverteh-os/updates.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const data = JSON.parse(text());
                root.count = parseInt(String(data.text ?? 0).match(/\d+/)?.[0] ?? "0");
            } catch (error) {
                root.count = 0;
            }
        }
    }
}
