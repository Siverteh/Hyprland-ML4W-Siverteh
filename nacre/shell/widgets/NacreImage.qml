import QtQuick
import QtQuick.Window

Image {
    id: root
    property string path: ""
    property bool loadOriginal: false
    property bool ready: false
    property url displayedSource: ""
    property size decodeSize: Qt.size(-1, -1)
    property string error: ""
    asynchronous: true
    cache: true
    retainWhileLoading: true
    fillMode: Image.PreserveAspectCrop
    source: displayedSource
    function urlFor(value) {
        return /^(file|https?|image|qrc):/.test(value) ? value : value ? "file://" + value : "";
    }
    function refresh() {
        if (!ready)
            return;
        error = "";
        decodeSize = loadOriginal ? Qt.size(-1, -1) : Qt.size(Math.max(1, Math.ceil(width * Screen.devicePixelRatio)), Math.max(1, Math.ceil(height * Screen.devicePixelRatio)));
        sourceSize = decodeSize;
        displayedSource = urlFor(path);
    }
    function schedule() {
        if (ready)
            pending.restart();
    }
    onPathChanged: schedule()
    onWidthChanged: schedule()
    onHeightChanged: schedule()
    onLoadOriginalChanged: schedule()
    Screen.onDevicePixelRatioChanged: schedule()
    onStatusChanged: {
        if (status === Image.Error) {
            error = "Image could not be loaded.";
            displayedSource = "";
        } else if (status === Image.Ready)
            error = "";
    }
    Component.onCompleted: {
        ready = true;
        refresh();
    }
    Timer {
        id: pending
        interval: 50
        onTriggered: root.refresh()
    }
}
