import "root:/config"
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities
    readonly property int galleryCount: visibilities.launcherMode === "wallpaper" ? content.item?.count ?? 0 : 0
    readonly property int galleryIndex: visibilities.launcherMode === "wallpaper" ? content.item?.currentIndex ?? -1 : -1
    function galleryStep(delta) { if(visibilities.launcher && visibilities.launcherMode === "wallpaper") content.item?.move(delta); }

    visible: height > 0
    implicitHeight: !visibilities.launcher ? 0 : visibilities.launcherMode === "wallpaper" ? LauncherConfig.sizes.wallpaperHeight + Appearance.padding.large * 4 : content.item?.implicitHeight ?? 0
    implicitWidth: content.item?.implicitWidth ?? LauncherConfig.sizes.itemWidth

    // Retarget on mode changes, including while an opening animation is in flight.
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.standard
        }
    }

    Component {id:apps;AppGrid {visibilities:root.visibilities}}
    Loader {
        id: content
        sourceComponent: root.visibilities.launcherMode === "wallpaper" ? gallery : root.visibilities.launcherQuery.length ? commands : apps
        Component { id: gallery; WallpaperGallery { visibilities: root.visibilities } }
        Component { id: commands; Content { visibilities: root.visibilities } }
    }
}
