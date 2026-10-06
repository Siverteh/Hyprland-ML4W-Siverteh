import qs.config
import qs.services
import qs.modules.extras as Extras
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities
    readonly property int galleryCount: visibilities.launcherMode === "wallpaper" ? content.item?.count ?? 0 : 0
    readonly property int galleryIndex: visibilities.launcherMode === "wallpaper" ? content.item?.currentIndex ?? -1 : -1
    function galleryStep(delta) { if(visibilities.launcher && visibilities.launcherMode === "wallpaper") content.item?.move(delta); }

    readonly property bool fullScreenGallery:visibilities.launcherMode==="wallpaper"&&(Wallpapers.preferences.layout??"carousel")!=="carousel"
    clip:true
    visible: height > 0
    implicitHeight: !visibilities.launcher ? 0 : fullScreenGallery ? Math.max(0,parent.height-24) : content.item?.implicitHeight ?? 0
    implicitWidth: fullScreenGallery ? Math.max(0,parent.width-48) : content.item?.implicitWidth ?? LauncherConfig.sizes.itemWidth

    // Retarget on mode changes, including while an opening animation is in flight.
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.standard
        }
    }

    Component {id:palette;Extras.Palette {visibilities:root.visibilities}}
    Component {id:overview;Extras.Overview {visibilities:root.visibilities}}
    Component {id:clipboard;Extras.Clipboard {visibilities:root.visibilities}}
    Component {id:keys;Extras.Keybindings {visibilities:root.visibilities}}
    Component {id:apps;AppGrid {visibilities:root.visibilities}}
    Loader {
        id: content
        width:root.width
        height:root.fullScreenGallery?Math.max(0,root.parent.height-24):item?.implicitHeight??0
        anchors.top:parent.top;anchors.left:parent.left
        active:root.visibilities.launcher||root.height>0
        sourceComponent:({palette:palette,overview:overview,clipboard:clipboard,keys:keys,legacy:commands,wallpaper:gallery,apps:apps})[root.visibilities.launcherMode]??apps
        Component { id: gallery; WallpaperGallery { visibilities: root.visibilities } }
        Component { id: commands; Content { visibilities: root.visibilities } }
    }
}
