import qs.widgets
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Controls

PathView {
    id: root

    property string filter: ""
    property bool initialized: false
    required property PersistentProperties visibilities
    readonly property int numItems: {
        const screenWidth = QsWindow.window?.screen.width * 0.8;
        if (!screenWidth)
            return 0;
        const itemWidth = NacreLauncher.sizes.wallpaperWidth * 0.8;
        const max = NacreLauncher.maxWallpapers;
        if (max * itemWidth > screenWidth) {
            const items = Math.floor(screenWidth / itemWidth);
            return items > 1 && items % 2 === 0 ? items - 1 : items;
        }
        return max;
    }

    model: ScriptModel {
        readonly property string search: root.filter

        values: {
            const list = Wallpapers.fuzzyQuery(search);
            return list;
        }
        onValuesChanged: root.currentIndex = search ? 0 : values.findIndex(w => w.path === Wallpapers.current)
    }

    Component.onCompleted: {
        currentIndex = Math.max(0, model.values.findIndex(w => w.path === Wallpapers.current));
        initialized = true;
    }
    Component.onDestruction: Wallpapers.commitSelection()

    onCurrentItemChanged: {
        if (initialized && currentItem && visibilities.launcher)
            Wallpapers.browse(currentItem.modelData.path);
    }

    implicitWidth: Math.min(numItems, count) * (NacreLauncher.sizes.wallpaperWidth * 0.8 + NacreAppearance.padding.larger * 2)
    pathItemCount: numItems
    cacheItemCount: 4

    snapMode: PathView.SnapToItem
    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5
    highlightRangeMode: PathView.StrictlyEnforceRange

    delegate: WallpaperItem {
        visibilities: root.visibilities
    }

    path: Path {
        startY: root.height / 2

        PathAttribute {
            name: "z"
            value: 0
        }
        PathLine {
            x: root.width / 2
            relativeY: 0
        }
        PathAttribute {
            name: "z"
            value: 1
        }
        PathLine {
            x: root.width
            relativeY: 0
        }
    }
}
