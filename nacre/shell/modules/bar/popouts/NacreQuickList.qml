import QtQuick
import QtQuick.Controls.Basic
import qs.widgets

Flickable {
    id: root
    property real maximumHeight: 210
    implicitWidth: 320
    implicitHeight: Math.max(0, Math.min(maximumHeight, contentHeight))
    contentWidth: width
    contentHeight: contentItem.children.length ? contentItem.children[0].implicitHeight : 0
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.VerticalFlick
    maximumFlickVelocity: 2200
    flickDeceleration: 2800
    onContentHeightChanged: if (contentY > Math.max(0, contentHeight - height)) {
        wheelGlide.stop();
        contentY = Math.max(0, contentHeight - height);
    }
    onMovementStarted: wheelGlide.stop()
    onVisibleChanged: if (!visible)
        wheelGlide.stop()
    NumberAnimation {
        id: wheelGlide
        target: root
        property: "contentY"
        duration: NacreTokens.motionEnabled ? 160 : 0
        easing.type: Easing.OutCubic
    }
    ScrollBar.vertical: NacreScrollBar {}
    WheelHandler {
        target: null
        onWheel: event => {
            const amount = event.pixelDelta.y || event.angleDelta.y / 120 * 72;
            if (amount) {
                const start = root.contentY;
                const destination = Math.max(0, Math.min(Math.max(0, root.contentHeight - root.height), (wheelGlide.running ? wheelGlide.to : start) - amount));
                wheelGlide.stop();
                wheelGlide.from = start;
                wheelGlide.to = destination;
                wheelGlide.start();
                event.accepted = true;
            }
        }
    }
}
