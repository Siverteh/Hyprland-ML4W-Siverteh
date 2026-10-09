import QtQuick
import qs.services

Image {
    id: root
    property string path: ""
    property bool loadOriginal: false
    property var thumbnail: null
    property bool ready: false
    property url displayedSource: ""
    asynchronous: true
    cache: true
    retainWhileLoading: true
    fillMode: Image.PreserveAspectCrop
    source: displayedSource
    function acceptThumbnail() {
        const value = thumbnail?.path;
        if (value)
            displayedSource = String(value).startsWith("file:") ? value : "file://" + value;
    }
    function refresh() {
        if (!ready)
            return;
        if (thumbnail)
            thumbnail.destroy();
        thumbnail = path && width > 0 && height > 0 ? Thumbnailer.go(root) : null;
        if (!path)
            displayedSource = "";
        acceptThumbnail();
    }
    function schedule() {
        if (ready)
            pending.restart();
    }
    onPathChanged: schedule()
    onWidthChanged: schedule()
    onHeightChanged: schedule()
    onLoadOriginalChanged: schedule()
    Component.onCompleted: {
        ready = true;
        refresh();
    }
    Connections {
        target: root.thumbnail
        function onPathChanged() {
            root.acceptThumbnail();
        }
    }
    Timer {
        id: pending
        interval: 50
        onTriggered: root.refresh()
    }
}
