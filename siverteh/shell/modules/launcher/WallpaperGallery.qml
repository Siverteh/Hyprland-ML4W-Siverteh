pragma ComponentBehavior: Bound
import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import QtQuick

Item {
    id: root
    required property PersistentProperties visibilities
    implicitWidth: walls.implicitWidth + Appearance.padding.large * 2 + 72
    implicitHeight: LauncherConfig.sizes.wallpaperHeight + Appearance.padding.large * 4
    focus: true
    readonly property int count: walls.count
    readonly property int currentIndex: walls.currentIndex
    function move(delta) { if(delta>0) walls.incrementCurrentIndex(); else walls.decrementCurrentIndex(); }

    function choose() {
        if (!walls.currentItem) return;
        Wallpapers.setWallpaper(walls.currentItem.modelData.path);
        visibilities.launcher = false;
    }
    Component.onCompleted: if(visibilities.launcher) forceActiveFocus()
    Connections {
        target:root.visibilities
        function onLauncherChanged() {
            if(root.visibilities.launcher) {
                root.forceActiveFocus();
                if(walls.currentItem) Wallpapers.browse(walls.currentItem.modelData.path);
            } else {if(walls.currentItem)Wallpapers.browse(walls.currentItem.modelData.path);Wallpapers.commitSelection();}
        }
    }
    Keys.onLeftPressed: move(-1)
    Keys.onRightPressed: move(1)
    Keys.onUpPressed: move(-1)
    Keys.onDownPressed: move(1)
    Keys.onReturnPressed: choose()
    Keys.onEnterPressed: choose()
    Keys.onEscapePressed: visibilities.launcher=false

    WallpaperList {
        id:walls
        visibilities:root.visibilities
        anchors.centerIn:parent
        height:LauncherConfig.sizes.wallpaperHeight
        WheelHandler {
            target: null
            onWheel: event => {
                if(event.angleDelta.y>0) root.move(-1);
                else if(event.angleDelta.y<0) root.move(1);
                event.accepted=true;
            }
        }
    }
    MaterialIcon {
        anchors.left:parent.left;anchors.leftMargin:Appearance.padding.large
        anchors.verticalCenter:parent.verticalCenter
        text:"chevron_left"
        MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.move(-1)}
    }
    MaterialIcon {
        anchors.right:parent.right;anchors.rightMargin:Appearance.padding.large
        anchors.verticalCenter:parent.verticalCenter
        text:"chevron_right"
        MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.move(1)}
    }
}
