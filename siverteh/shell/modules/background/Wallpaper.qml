pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick
import QtQuick.Window

Item {
    id: root

    property string screenName:""
    property url source: Wallpapers.poster ? `file://${Wallpapers.poster}` : ""
    readonly property var monitor:Hyprland.monitors.values.find(m=>m.name===screenName)
    readonly property int workspaceId:monitor?.activeWorkspace?.id??Hyprland.activeWsId
    readonly property bool pickerOpen:Object.values(Visibilities.screens).some(v=>v.launcher&&v.launcherMode==="wallpaper")
    readonly property bool covered:Hyprland.clients.some(c=>c.workspace?.id===workspaceId&&(c.fullscreen||(WallpaperPlayback.pauseCovered&&!c.floating)))
    readonly property bool motionAllowed:!WallpaperPlayback.sleeping&&!WallpaperPlayback.locked&&!WallpaperPlayback.paused&&(!covered||pickerOpen)
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

    AnimatedImage {anchors.fill:parent;source:Wallpapers.dynamic&&Wallpapers.animated?"file://"+Wallpapers.current:"";fillMode:Image.PreserveAspectCrop;playing:root.motionAllowed;visible:source.toString().length>0&&status===Image.Ready;asynchronous:true;cache:false}
    Loader {id:video;anchors.fill:parent;active:Wallpapers.dynamic&&!Wallpapers.animated;source:"DynamicWallpaper.qml";onLoaded:{item.screenName=root.screenName;item.path=Qt.binding(()=>Wallpapers.current);item.running=Qt.binding(()=>root.motionAllowed);}}

    component Img: CachingImage {
        id: img

        function update(): void {
            const srcPath = decodeURIComponent(`${root.source}`.slice(7));
            if (thumbnail.originalPath === srcPath) {
                root.current = this;
            } else
                path = srcPath;
        }

        anchors.fill: parent

        sourceSize.width:Math.ceil(width*Screen.devicePixelRatio)
        sourceSize.height:Math.ceil(height*Screen.devicePixelRatio)
        loadOriginal: true
        asynchronous: true
        cache: false
        fillMode: Image.PreserveAspectCrop

        opacity: 0
        scale: 0.8

        onStatusChanged: {
            if (status === Image.Ready)
                root.current = this;
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
