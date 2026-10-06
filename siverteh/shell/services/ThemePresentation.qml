pragma Singleton
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property var pending: ({})
    property var active: ({})
    readonly property bool available: !!pending.colours
    function accept(data) {
        if (!data?.colours || !data.poster)
            return;
        pending = data;
        if (!active.colours || active.poster === data.poster)
            active = data;
    }
    function activate(poster) {
        if (pending.poster === poster)
            active = pending;
    }
    FileView {
        path: `${Paths.state}/presentation.json`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.accept(JSON.parse(text()));
            } catch (e) {}
        }
    }
}
