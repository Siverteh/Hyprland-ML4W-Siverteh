import qs.services
import QtQuick

Item {
    id: root
    implicitWidth: 30
    implicitHeight: 30
    Accessible.name: "Siverteh OS apps"
    Accessible.role: Accessible.Button
    property bool compact: false
    function adjust(value) {
        return compact ? value.replace(/L24 2 L24 12/g, "L24.6 2 L24.6 12").replace(/L24 14 L24 24/g, "L24.6 14 L24.6 24") : value;
    }
    property color primary: Colours.palette.m3primary
    property color secondary: Colours.palette.m3secondary
    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        sourceSize.width: 192
        sourceSize.height: 192
        source: "data:image/svg+xml;utf8," + encodeURIComponent(root.adjust("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 34 28\"><path class=\"outline-primary\" d=\"M2 2 L16 2 L16 6 L14 6 L14 4 L4 4 L4 12 L16 12 L16 24 L2 24 L2 22 L14 22 L14 14 L2 14Z\" transform=\"translate(0.7 0.9)\" fill=\"none\" stroke=\"@PRIMARY@\" stroke-width=\"0.24\"/><path class=\"outline-primary\" d=\"M2 2 L16 2 L16 6 L14 6 L14 4 L4 4 L4 12 L16 12 L16 24 L2 24 L2 22 L14 22 L14 14 L2 14Z\" transform=\"translate(1.4 1.8)\" fill=\"none\" stroke=\"@PRIMARY@\" stroke-width=\"0.24\"/><path class=\"face-primary\" d=\"M2 2 L16 2 L16 6 L14 6 L14 4 L4 4 L4 12 L16 12 L16 24 L2 24 L2 22 L14 22 L14 14 L2 14Z\" fill=\"@PRIMARY@\"/><path class=\"outline-secondary\" d=\"M22 2 L24 2 L24 12 L30 12 L30 2 L32 2 L32 24 L30 24 L30 14 L24 14 L24 24 L22 24Z\" transform=\"translate(0.7 0.9)\" fill=\"none\" stroke=\"@SECONDARY@\" stroke-width=\"0.24\"/><path class=\"outline-secondary\" d=\"M22 2 L24 2 L24 12 L30 12 L30 2 L32 2 L32 24 L30 24 L30 14 L24 14 L24 24 L22 24Z\" transform=\"translate(1.4 1.8)\" fill=\"none\" stroke=\"@SECONDARY@\" stroke-width=\"0.24\"/><path class=\"face-secondary\" d=\"M22 2 L24 2 L24 12 L30 12 L30 2 L32 2 L32 24 L30 24 L30 14 L24 14 L24 24 L22 24Z\" fill=\"@SECONDARY@\"/></svg>".replace(/@PRIMARY@/g, String(root.primary)).replace(/@SECONDARY@/g, String(root.secondary))))
    }
}
