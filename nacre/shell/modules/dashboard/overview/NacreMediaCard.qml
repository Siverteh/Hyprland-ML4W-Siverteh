import QtQuick
import QtQuick.Shapes
import qs.widgets
import qs.services
import "overview.js" as Overview

NacreOverviewCard {
    id: root
    property bool active: false
    readonly property var player: NacrePlayers.active
    property real positionSeconds: 0
    property bool artReady: false
    property string artUrl: ""
    readonly property bool sampling: sample.running
    readonly property real progress: player?.positionSupported && player?.lengthSupported ? Overview.progress(positionSeconds, player.length) : 0
    readonly property real artSize: Math.max(40, Math.min(width - 48, 174, height - 190))
    function refresh() {
        positionSeconds = player?.positionSupported ? player.position : 0;
    }
    function refreshArt() {
        if (active)
            artUrl = player?.trackArtUrl || "";
    }
    function perform(action) {
        const current = player;
        if (!active || !current?.canControl)
            return;
        if (action === "previous" && current.canGoPrevious)
            current.previous();
        else if (action === "toggle" && current.canTogglePlaying)
            current.togglePlaying();
        else if (action === "next" && current.canGoNext)
            current.next();
    }
    onPlayerChanged: {
        refresh();
        if (!player)
            artUrl = "";
        else
            refreshArt();
    }
    onActiveChanged: if (active) {
        refresh();
        refreshArt();
    }
    Component.onCompleted: {
        refresh();
        refreshArt();
    }
    Connections {
        target: root.player
        ignoreUnknownSignals: true
        function onTrackChanged() {
            root.positionSeconds = 0;
        }
        function onPostTrackChanged() {
            root.refresh();
            root.refreshArt();
        }
        function onTrackArtUrlChanged() {
            root.refreshArt();
        }
        function onPositionChanged() {
            root.refresh();
        }
    }
    Timer {
        id: sample
        interval: 1000
        running: !!(root.active && root.visible && root.player?.isPlaying && root.player?.positionSupported && root.player?.lengthSupported)
        repeat: true
        onTriggered: root.refresh()
    }
    Item {
        id: art
        y: 20
        width: root.artSize + 12
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        NacreClip {
            id: album
            anchors.centerIn: parent
            width: root.artSize
            height: width
            radius: width / 2
            color: Colours.palette.m3surfaceContainerHigh
            Image {
                id: cover
                objectName: "mediaCover"
                anchors.fill: parent
                source: root.artUrl
                asynchronous: true
                cache: true
                retainWhileLoading: true
                sourceSize.width: 320
                sourceSize.height: 320
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready || status === Image.Loading && root.artReady
                onStatusChanged: {
                    if (status === Image.Ready)
                        root.artReady = true;
                    else if (status === Image.Error || status === Image.Null)
                        root.artReady = false;
                }
            }
            NacreIcon {
                anchors.centerIn: parent
                visible: !cover.visible
                text: "music_note"
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: 36
            }
        }
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeColor: Colours.palette.m3primary
                strokeWidth: 5
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                PathAngleArc {
                    centerX: art.width / 2
                    centerY: art.height / 2
                    radiusX: art.width / 2 - 3
                    radiusY: radiusX
                    startAngle: -90
                    sweepAngle: root.progress * 360
                }
            }
        }
    }
    Column {
        id: metadata
        x: 14
        y: art.y + art.height + 14
        width: root.width - 28
        spacing: 8
        NacreText {
            objectName: "mediaTitle"
            width: parent.width
            text: root.player ? root.player.trackTitle || "Unknown track" : "No media playing"
            font.pointSize: 12
            color: Colours.palette.m3primary
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
        NacreText {
            width: parent.width
            text: root.player?.trackAlbum || ""
            visible: text.length > 0
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: 10
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
        NacreText {
            width: parent.width
            text: root.player ? root.player.trackArtist || root.player.identity : "Open a music or video app"
            color: Colours.palette.m3secondary
            font.pointSize: 10
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }
    Row {
        id: controls
        y: Math.min(root.height - 48, metadata.y + metadata.height + 16)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6
        Transport {
            objectName: "mediaPrevious"
            icon: "skip_previous"
            label: "Previous track"
            available: !!(root.active && root.player?.canControl && root.player?.canGoPrevious)
            onActivated: root.perform("previous")
        }
        Transport {
            objectName: "mediaToggle"
            icon: root.player?.isPlaying ? "pause" : "play_arrow"
            label: root.player?.isPlaying ? "Pause" : "Play"
            available: !!(root.active && root.player?.canControl && root.player?.canTogglePlaying)
            onActivated: root.perform("toggle")
        }
        Transport {
            objectName: "mediaNext"
            icon: "skip_next"
            label: "Next track"
            available: !!(root.active && root.player?.canControl && root.player?.canGoNext)
            onActivated: root.perform("next")
        }
    }
    Rectangle {
        x: 20
        y: parent.height - 18
        width: Math.max(0, parent.width - 40)
        height: 2
        radius: 1
        color: Colours.palette.m3outlineVariant
        Rectangle {
            width: root.progress * parent.width
            height: 2
            radius: 1
            color: Colours.palette.m3primary
        }
    }
    component Transport: NacreSurface {
        required property string icon
        required property string label
        property bool available: false
        signal activated
        width: 34
        height: 34
        radius: 17
        color: "transparent"
        opacity: available ? 1 : 0.35
        NacreIcon {
            anchors.centerIn: parent
            text: parent.icon
            font.pointSize: 17
        }
        NacreInteraction {
            disabled: !parent.available
            accessibleName: parent.label
            function onClicked() {
                parent.activated();
            }
        }
    }
}
