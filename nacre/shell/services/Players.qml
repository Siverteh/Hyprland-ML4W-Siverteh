pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    readonly property var list: NacrePlayers.list
    readonly property var active: NacrePlayers.active
    property var manualActive: NacrePlayers.manualActive
    Connections {
        target: NacrePlayers
        function onManualActiveChanged() {
            if (root.manualActive !== NacrePlayers.manualActive)
                root.manualActive = NacrePlayers.manualActive;
        }
    }
    onManualActiveChanged: if (manualActive !== NacrePlayers.manualActive)
        NacrePlayers.manualActive = manualActive
}
