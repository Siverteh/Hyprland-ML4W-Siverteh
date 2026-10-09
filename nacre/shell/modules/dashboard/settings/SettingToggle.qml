import QtQuick
import qs.services
import qs.widgets

Item {
    id: root

    property string label
    property string setting
    readonly property bool checked: DesktopSettings.data[setting] === true

    width: parent.width
    height: 36

    StyledText {
        width: parent.width - 62
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        elide: Text.ElideRight
        font.pointSize: 11
    }

    StyledRect {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 46
        height: 26
        radius: 13
        color: root.checked ? Colours.palette.m3primary : Colours.palette.m3surfaceContainerHighest

        Rectangle {
            x: root.checked ? 23 : 3
            y: 3
            width: 20
            height: 20
            radius: 10
            color: root.checked ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: DesktopSettings.set(root.setting, !root.checked)
    }
}
