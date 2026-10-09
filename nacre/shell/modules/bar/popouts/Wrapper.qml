import QtQuick
import Quickshell
import qs.config
import qs.services

Item {
    id: root

    required property ShellScreen screen
    property alias currentName: content.currentName
    property alias currentCenter: content.currentCenter
    property alias hasCurrent: content.hasCurrent
    property bool headerHovered: false
    property bool pinned: false
    readonly property real targetWidth: content.targetWidth

    onHasCurrentChanged: {
        if (!hasCurrent) {
            pinned = false;
        }
    }
    visible: width > 0 && height > 0
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Content {
        id: content

        screen: root.screen
    }
}
