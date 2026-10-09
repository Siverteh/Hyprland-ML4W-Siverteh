import QtQuick
import qs.services
import qs.config

Item {
    id: root
    required property var screen
    required property var visibilities
    required property bool hovered
    readonly property var monitor: NacreBrightness.getMonitorForScreen(screen)
    property bool armed: false
    property bool audioBaseline: false
    readonly property bool audioReady: NacreAudio.available
    function show() {
        if (!armed || visibilities.session || WallpaperPlayback.locked || screen.name !== NacreHyprland.focusedMonitor?.name)
            return;
        visibilities.osd = true;
        expiry.restart();
    }
    onAudioReadyChanged: {
        audioBaseline = false;
        Qt.callLater(() => audioBaseline = audioReady);
    }
    Component.onCompleted: Qt.callLater(() => {
        armed = true;
        audioBaseline = audioReady;
    })
    Connections {
        target: NacreAudio
        function onVolumeChanged() {
            if (root.audioBaseline)
                root.show();
        }
        function onMutedChanged() {
            if (root.audioBaseline)
                root.show();
        }
    }
    Connections {
        target: root.monitor
        function onAdjusted() {
            root.show();
        }
    }
    Connections {
        target: NacreKeyboardLight
        function onAdjusted() {
            root.show();
        }
    }
    onHoveredChanged: if (hovered)
        expiry.stop()
    else if (visibilities.osd)
        expiry.restart()
    Timer {
        id: expiry
        interval: NacreOsd.hideDelay
        onTriggered: if (!root.hovered)
            root.visibilities.osd = false
    }
}
