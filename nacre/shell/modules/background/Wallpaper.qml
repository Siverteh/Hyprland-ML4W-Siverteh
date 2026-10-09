pragma ComponentBehavior: Bound

import qs.widgets
import qs.services
import qs.config
import Quickshell.Io
import QtQuick
import QtQuick.Window

Item {
    id: root

    property string screenName: ""
    property url source: NacreWallpapers.pendingPoster ? `file://${NacreWallpapers.pendingPoster}` : ""
    readonly property var monitor: NacreHyprland.monitors.values.find(m => m.name === screenName)
    readonly property int workspaceId: monitor?.activeWorkspace?.id ?? NacreHyprland.activeWsId
    readonly property bool pickerOpen: Object.values(Visibilities.screens).some(v => v.launcher && v.launcherMode === "wallpaper")
    readonly property bool covered: NacreHyprland.clients.some(c => c.workspace?.id === workspaceId && (c.fullscreen || (WallpaperPlayback.pauseCovered && !c.floating)))
    readonly property bool motionAllowed: !WallpaperPlayback.sleeping && !WallpaperPlayback.locked && !WallpaperPlayback.paused && !WallpaperPlayback.batteryPaused && !pickerOpen && !covered
    property Image current: one

    anchors.fill: parent

    onSourceChanged: {
        if (current === one)
            two.update();
        else
            one.update();
    }

    Img {
        id: one
    }

    Img {
        id: two
    }

    AnimatedImage {
        anchors.fill: parent
        source: !WallpaperPlayback.batteryPaused && NacreWallpapers.displayDynamic && NacreWallpapers.displayAnimated ? "file://" + NacreWallpapers.displayPath : ""
        fillMode: Image.PreserveAspectCrop
        playing: root.motionAllowed
        visible: source.toString().length > 0 && status === Image.Ready
        asynchronous: true
        cache: false
    }
    Loader {
        id: video
        anchors.fill: parent
        active: !WallpaperPlayback.batteryPaused && NacreWallpapers.displayDynamic && !NacreWallpapers.displayAnimated
        source: "DynamicWallpaper.qml"
        onLoaded: {
            item.screenName = root.screenName;
            item.path = Qt.binding(() => NacreWallpapers.displayPath);
            item.running = Qt.binding(() => root.motionAllowed);
        }
    }

    IpcHandler {
        target: "wallpaperFrame-" + root.screenName
        function state(): string {
            return JSON.stringify({
                displayed: root.current.path,
                status: root.current.status,
                pending: NacrePresentation.pending.poster,
                active: NacrePresentation.active.poster,
                color: String(NacreColours.palette.m3primary),
                secondary: String(NacreColours.palette.m3secondary),
                tertiary: String(NacreColours.palette.m3tertiary),
                frame: String(NacreFrame.colour),
                decorativeFrame: NacrePresentation.active.colours?.frame ?? "",
                expectedFrame: NacrePresentation.active.colours?.surface ?? "",
                paletteChoices: NacrePresentation.active.paletteOptions?.length ?? 0,
                selectedAccent: NacrePresentation.active.selectedAccent ?? "",
                motionAllowed: root.motionAllowed,
                decoderActive: video.active,
                batteryPaused: WallpaperPlayback.batteryPaused,
                expected: NacrePresentation.active.colours?.primary ?? ""
            });
        }
    }

    component Img: Image {
        id: img
        property string path: ""
        source: path ? "file://" + path : ""

        function update(): void {
            const srcPath = decodeURIComponent(`${root.source}`.slice(7));
            if (path === srcPath && status === Image.Ready) {
                root.current = this;
                NacrePresentation.activate(srcPath);
            } else
                path = srcPath;
        }

        anchors.fill: parent

        sourceSize.width: Math.ceil(width * Screen.devicePixelRatio)
        sourceSize.height: Math.ceil(height * Screen.devicePixelRatio)
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop

        opacity: 0
        scale: 0.8

        onStatusChanged: {
            if (status === Image.Ready && path === decodeURIComponent(root.source.toString().slice(7))) {
                root.current = this;
                NacrePresentation.activate(path);
            }
        }

        states: State {
            name: "visible"
            when: root.current === img

            PropertyChanges {
                img.opacity: 1
                img.scale: 1
            }
        }

        transitions: Transition {
            NumberAnimation {
                target: img
                properties: "opacity,scale"
                duration: NacreAppearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: NacreAppearance.anim.curves.standard
            }
        }
    }
}
