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
    property url source: Wallpapers.pendingPoster ? `file://${Wallpapers.pendingPoster}` : ""
    readonly property var monitor: Hyprland.monitors.values.find(m => m.name === screenName)
    readonly property int workspaceId: monitor?.activeWorkspace?.id ?? Hyprland.activeWsId
    readonly property bool pickerOpen: Object.values(Visibilities.screens).some(v => v.launcher && v.launcherMode === "wallpaper")
    readonly property bool covered: Hyprland.clients.some(c => c.workspace?.id === workspaceId && (c.fullscreen || (WallpaperPlayback.pauseCovered && !c.floating)))
    readonly property bool motionAllowed: !WallpaperPlayback.sleeping && !WallpaperPlayback.locked && !WallpaperPlayback.paused && !pickerOpen && !covered
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
        source: Wallpapers.displayDynamic && Wallpapers.displayAnimated ? "file://" + Wallpapers.displayPath : ""
        fillMode: Image.PreserveAspectCrop
        playing: root.motionAllowed
        visible: source.toString().length > 0 && status === Image.Ready
        asynchronous: true
        cache: false
    }
    Loader {
        id: video
        anchors.fill: parent
        active: Wallpapers.displayDynamic && !Wallpapers.displayAnimated
        source: "DynamicWallpaper.qml"
        onLoaded: {
            item.screenName = root.screenName;
            item.path = Qt.binding(() => Wallpapers.displayPath);
            item.running = Qt.binding(() => root.motionAllowed);
        }
    }

    IpcHandler {
        target: "wallpaperFrame-" + root.screenName
        function state(): string {
            return JSON.stringify({
                displayed: root.current.path,
                status: root.current.status,
                pending: ThemePresentation.pending.poster,
                active: ThemePresentation.active.poster,
                color: String(Colours.palette.m3primary),
                expected: ThemePresentation.active.colours?.primary ?? ""
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
                ThemePresentation.activate(srcPath);
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
                ThemePresentation.activate(path);
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
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }
    }
}
