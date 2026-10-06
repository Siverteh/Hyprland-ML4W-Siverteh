import qs.services
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property ShellScreen screen

    property alias currentName: content.currentName
    property alias currentCenter: content.currentCenter
    property alias hasCurrent: content.hasCurrent
    property bool headerHovered: false
    property bool pinned: false
    onHasCurrentChanged: if (!hasCurrent)
        pinned = false
    readonly property real targetWidth: content.targetWidth

    visible: width > 0 && height > 0

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Content {
        id: content

        screen: root.screen
    }
}
