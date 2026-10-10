import QtQuick
import qs.widgets
import qs.services

Item {
    id: root
    required property var screen
    required property bool visibility
    property real presentedWidth: 0
    implicitWidth: Math.max(0, presentedWidth)
    readonly property real contentWidth: controls.item?.implicitWidth ?? 170
    implicitHeight: controls.item?.implicitHeight ?? 328
    visible: width > 0
    enabled: visibility
    clip: true
    function syncSize() {
        presentedWidth = visibility ? contentWidth : 0;
    }
    onVisibilityChanged: syncSize()
    onContentWidthChanged: syncSize()
    Component.onCompleted: syncSize()
    Loader {
        id: controls
        active: root.visibility || root.presentedWidth > 0
        width: root.contentWidth
        height: root.implicitHeight
        sourceComponent: NacreOsdControls {
            monitor: NacreBrightness.getMonitorForScreen(root.screen)
        }
    }
    Behavior on presentedWidth {
        enabled: NacreTokens.motionEnabled
        NumberAnimation {
            id: motion
            duration: 180
            easing.type: Easing.OutCubic
        }
    }
    Connections {
        target: NacreTokens
        function onMotionEnabledChanged() {
            if (!NacreTokens.motionEnabled) {
                motion.stop();
                root.syncSize();
            }
        }
    }
}
