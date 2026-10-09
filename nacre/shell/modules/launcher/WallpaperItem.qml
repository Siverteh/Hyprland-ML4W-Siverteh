import qs.widgets
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Effects

NacreSurface {
    id: root

    required property Wallpapers.Wallpaper modelData
    required property PersistentProperties visibilities

    scale: 0.5
    opacity: 0
    z: PathView.z ?? 0

    Component.onCompleted: {
        scale = Qt.binding(() => PathView.isCurrentItem ? 1 : PathView.onPath ? 0.8 : 0);
        opacity = Qt.binding(() => PathView.onPath ? 1 : 0);
    }

    implicitWidth: image.width + NacreAppearance.padding.larger * 2
    implicitHeight: image.height + label.height + NacreAppearance.spacing.small / 2 + NacreAppearance.padding.large + NacreAppearance.padding.normal

    NacreInteraction {
        radius: NacreAppearance.rounding.normal

        function onClicked(): void {
            Wallpapers.setWallpaper(root.modelData.path);
            root.visibilities.launcher = false;
        }
    }

    NacreImage {
        id: image

        anchors.horizontalCenter: parent.horizontalCenter
        y: NacreAppearance.padding.large

        visible: false
        path: root.modelData.path
        smooth: !root.PathView.view.moving

        width: NacreLauncher.sizes.wallpaperWidth
        height: width / 16 * 9
    }

    Rectangle {
        id: mask

        layer.enabled: true
        layer.smooth: true
        visible: false
        anchors.fill: image
        radius: NacreAppearance.rounding.normal
    }

    RectangularShadow {
        opacity: root.PathView.isCurrentItem ? 0.7 : 0
        anchors.fill: mask
        radius: mask.radius
        color: Colours.palette.m3shadow
        blur: 10
        spread: 3

        Behavior on opacity {
            Anim {}
        }
    }

    MultiEffect {
        anchors.fill: image
        source: image
        maskEnabled: true
        maskSource: mask
        maskSpreadAtMin: 1
        maskThresholdMin: 0.5
    }

    NacreText {
        id: label

        anchors.top: image.bottom
        anchors.topMargin: NacreAppearance.spacing.small / 2
        anchors.horizontalCenter: parent.horizontalCenter

        width: image.width - NacreAppearance.padding.normal * 2
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        renderType: Text.QtRendering
        text: root.modelData.name
        font.pointSize: NacreAppearance.font.size.normal
    }

    Behavior on scale {
        Anim {}
    }

    Behavior on opacity {
        Anim {}
    }

    component Anim: NumberAnimation {
        duration: NacreAppearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: NacreAppearance.anim.curves.standard
    }
}
