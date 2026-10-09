import QtQuick
import QtMultimedia

Item {
    id: root
    property var entry: null
    property bool running: false
    property bool active: false
    visible: active
    function refresh() {
        active = false;
        settle.stop();
        if (running && entry?.dynamic)
            settle.start();
    }
    onRunningChanged: refresh()
    onEntryChanged: refresh()
    Component.onCompleted: refresh()
    Timer {
        id: settle
        interval: 180
        onTriggered: root.active = root.running && root.entry?.dynamic === true
    }
    Loader {
        anchors.fill: parent
        active: root.active
        sourceComponent: root.entry?.animated ? animation : video
    }
    Component {
        id: animation
        AnimatedImage {
            source: "file://" + root.entry.path
            asynchronous: true
            playing: root.active
            fillMode: Image.PreserveAspectCrop
        }
    }
    Component {
        id: video
        Item {
            VideoOutput {
                id: output
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
            }
            MediaPlayer {
                source: "file://" + root.entry.path
                videoOutput: output
                audioOutput: null
                activeAudioTrack: -1
                loops: MediaPlayer.Infinite
                Component.onCompleted: play()
            }
        }
    }
}
