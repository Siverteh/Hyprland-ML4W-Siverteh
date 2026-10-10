import QtQuick
import QtQuick.Shapes
import qs.config
import qs.widgets
import qs.services

Item {
    id: root
    required property var host
    readonly property real radius: Math.max(0, Math.min(NacreFrame.rounding, host.width / 2, host.height / 2))
    readonly property string boundary: "M0 0 H" + width + " V" + height + " H0 Z " + roundedHole(host.x, host.y, host.width, host.height, radius)
    function roundedHole(x, y, w, h, r) {
        if (w <= 0 || h <= 0)
            return "";
        const tl = NacreFrame.left > 0 && NacreFrame.headerHeight > 0 ? r : 0;
        const tr = NacreFrame.right > 0 && NacreFrame.headerHeight > 0 ? r : 0;
        const bl = NacreFrame.left > 0 && NacreFrame.bottom > 0 ? r : 0;
        const br = NacreFrame.right > 0 && NacreFrame.bottom > 0 ? r : 0;
        return `M${x + tl} ${y} H${x + w - tr} Q${x + w} ${y} ${x + w} ${y + tr} V${y + h - br} Q${x + w} ${y + h} ${x + w - br} ${y + h} H${x + bl} Q${x} ${y + h} ${x} ${y + h - bl} V${y + tl} Q${x} ${y} ${x + tl} ${y} Z`;
    }
    function joinPath(panel, edge) {
        const x = host.x + panel.x, y = host.y + panel.y;
        const w = panel.width, h = panel.height;
        const r = Math.min(radius, w / 2, h / 2);
        if (r <= 0)
            return "";
        function ear(ax, ay, ox, oy, ix, iy) {
            return `M${ax + ox * r} ${ay + oy * r} L${ax} ${ay} L${ax + ix * r} ${ay + iy * r} Q${ax} ${ay} ${ax + ox * r} ${ay + oy * r} Z`;
        }
        if (edge === "left")
            return ear(x, y, 0, -1, 1, 0) + ear(x, y + h, 0, 1, 1, 0);
        if (edge === "right")
            return ear(x + w, y, 0, -1, -1, 0) + ear(x + w, y + h, 0, 1, -1, 0);
        if (edge === "bottom")
            return ear(x, y + h, -1, 0, 0, -1) + ear(x + w, y + h, 1, 0, 0, -1);
        if (edge === "top-right")
            return ear(x, y, -1, 0, 0, 1) + ear(x + w, y + h, 0, 1, -1, 0);
        return ear(x, y, -1, 0, 0, 1) + ear(x + w, y, 1, 0, 0, 1);
    }
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: NacreTokens.body
            strokeWidth: 0
            fillRule: ShapePath.OddEvenFill
            PathSvg {
                path: root.boundary
            }
        }
    }
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillRule: ShapePath.OddEvenFill
            strokeWidth: 0
            fillGradient: LinearGradient {
                x1: 0
                y1: 0
                x2: root.width
                y2: root.height
                GradientStop {
                    position: 0
                    color: Qt.alpha(NacreTokens.accent, .35)
                }
                GradientStop {
                    position: .5
                    color: Qt.alpha(NacreColours.palette.m3secondary, .35)
                }
                GradientStop {
                    position: 1
                    color: Qt.alpha(NacreColours.palette.m3tertiary, .35)
                }
            }
            PathSvg {
                path: root.roundedHole(root.host.x - 1, root.host.y - 1, root.host.width + 2, root.host.height + 2, root.radius + 1) + root.roundedHole(root.host.x, root.host.y, root.host.width, root.host.height, root.radius)
            }
        }
    }
    Repeater {
        model: [
            {
                item: root.host.leftDrawer,
                edge: "left"
            },
            {
                item: root.host.osd,
                edge: "right"
            },
            {
                item: root.host.session,
                edge: "right"
            },
            {
                item: root.host.dashboard,
                edge: "top"
            },
            {
                item: root.host.popouts,
                edge: root.host.popouts.joinsRight ? "top-right" : "top"
            },
            {
                item: root.host.notifications,
                edge: "top-right"
            },
            {
                item: root.host.launcher,
                edge: "bottom"
            }
        ]
        Item {
            id: attachedPanel
            required property var modelData
            readonly property var panel: modelData.item
            x: root.host.x + panel.x
            y: root.host.y + panel.y
            width: panel.width
            height: panel.height
            visible: width > 0 && height > 0 && !(modelData.edge === "bottom" && panel.fullScreenGallery === true)
            Shape {
                width: root.width
                height: root.height
                x: -attachedPanel.x
                y: -attachedPanel.y
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    fillColor: NacreTokens.body
                    strokeWidth: 0
                    PathSvg {
                        path: root.joinPath(attachedPanel.panel, attachedPanel.modelData.edge)
                    }
                }
            }
            Rectangle {
                anchors.fill: parent
                color: NacreTokens.body
                radius: Math.min(root.radius, width / 2, height / 2)
                topLeftRadius: attachedPanel.modelData.edge === "left" || attachedPanel.modelData.edge.startsWith("top") ? 0 : radius
                topRightRadius: attachedPanel.modelData.edge === "right" || attachedPanel.modelData.edge.startsWith("top") ? 0 : radius
                bottomLeftRadius: attachedPanel.modelData.edge === "left" || attachedPanel.modelData.edge === "bottom" ? 0 : radius
                bottomRightRadius: attachedPanel.modelData.edge === "right" || attachedPanel.modelData.edge === "bottom" || attachedPanel.modelData.edge === "top-right" ? 0 : radius
            }
        }
    }
}
