import QtQuick
import QtMultimedia

Item {
    id: root
    property var entry
    property bool running: false
    property bool settled: false
    readonly property bool active: media.active
    signal stateChanged(var data)

    function report() {
        stateChanged({
            path: entry?.path ?? "",
            active: media.active,
            playing: media.item?.playing ?? false,
            position: media.item?.position ?? 0,
            failure: media.item?.failure ?? ""
        });
    }
    function schedule() {
        settled = false;
        delay.stop();
        if (running)
            delay.restart();
        else
            report();
    }
    onRunningChanged: schedule()
    onEntryChanged: schedule()
    Component.onCompleted: schedule()
    Timer {
        id: delay
        interval: 180
        onTriggered: root.settled = true
    }
    Loader {
        id: media
        anchors.fill: parent
        active: root.running && root.settled && !!root.entry?.dynamic
        sourceComponent: root.entry?.animated ? gif : movie
        onLoaded: root.report()
        onActiveChanged: Qt.callLater(root.report)
    }
    Connections {
        target: media.item
        function onPlayingChanged() {
            root.report();
        }
        function onPositionChanged() {
            root.report();
        }
        function onFailureChanged() {
            root.report();
        }
    }
    Component {
        id: movie
        Item {
            id: videoPreview
            readonly property bool playing: player.playing
            readonly property int position: player.position
            property string failure: ""
            MediaPlayer {
                id: player
                source: "file://" + root.entry.path
                loops: MediaPlayer.Infinite
                videoOutput: output
                activeAudioTrack: -1
                onTracksChanged: activeAudioTrack = -1
                onErrorOccurred: (error, message) => {
                    videoPreview.failure = message;
                    stop();
                }
            }
            VideoOutput {
                id: output
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
                opacity: player.hasVideo && player.position > 0 ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                    }
                }
            }
            Component.onCompleted: player.play()
            Component.onDestruction: player.stop()
        }
    }
    Component {
        id: gif
        AnimatedImage {
            source: "file://" + root.entry.path
            fillMode: Image.PreserveAspectCrop
            playing: true
            cache: false
            readonly property int position: currentFrame
            readonly property string failure: status === Image.Error ? "Could not load animated image" : ""
        }
    }
}
