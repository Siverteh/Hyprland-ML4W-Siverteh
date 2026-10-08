import QtQuick
import QtQuick.Controls
import qs.services

Slider {
    id: root

    from: 0
    to: 1
    implicitHeight: 30

    background: Rectangle {
        x: root.leftPadding
        y: (root.height - height) / 2
        width: root.availableWidth
        height: 8
        radius: 4
        color: Colours.palette.m3surfaceContainerHighest

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: 4
            color: Colours.palette.m3primary
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: (root.height - height) / 2
        width: 22
        height: 22
        radius: 11
        color: Colours.palette.m3primary
        border.width: root.activeFocus ? 2 : 0
        border.color: Colours.palette.m3onPrimary
        opacity: root.enabled ? 1 : 0.4
    }
}
