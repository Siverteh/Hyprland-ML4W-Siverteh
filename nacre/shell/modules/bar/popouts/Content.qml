pragma ComponentBehavior: Bound
import qs.services
import qs.config
import Quickshell
import QtQuick

Item {
    id: root
    required property ShellScreen screen
    property string currentName
    property real currentCenter
    property bool hasCurrent
    property real lastWidth: 200
    property real lastHeight: 80
    readonly property real targetWidth: (body.item?.implicitWidth > 0 ? body.item.implicitWidth : lastWidth) + NacreAppearance.padding.large * 2
    readonly property real targetHeight: (body.item?.implicitHeight > 0 ? body.item.implicitHeight : lastHeight) + NacreAppearance.padding.large * 2
    anchors.centerIn: parent
    implicitWidth: targetWidth
    implicitHeight: hasCurrent ? targetHeight : 0
    Loader {
        id: body
        anchors.fill: parent
        anchors.margins: NacreAppearance.padding.large
        clip: true
        asynchronous: false
        source: ({
                audio: "Audio.qml",
                notifications: "Notifications.qml",
                network: "Network.qml",
                bluetooth: "Bluetooth.qml",
                calendar: "NacreCalendarPopup.qml",
                battery: "NacreBatteryPopup.qml"
            })[root.currentName] ?? ""
        onLoaded: {
            if (item.implicitWidth > 0)
                root.lastWidth = item.implicitWidth;
            if (item.implicitHeight > 0)
                root.lastHeight = item.implicitHeight;
        }
    }
    Behavior on implicitWidth {
        enabled: root.hasCurrent
        Anim {}
    }
    Behavior on implicitHeight {
        Anim {}
    }
    // Place a closed pane before its reveal; animate only an already-open pane.
    Behavior on currentCenter {
        enabled: root.hasCurrent
        Anim {}
    }
    component Anim: NumberAnimation {
        duration: NacreAppearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: NacreAppearance.anim.curves.standard
    }
}
