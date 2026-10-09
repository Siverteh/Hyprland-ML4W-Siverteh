import QtQuick
import qs.config
import qs.widgets

Item {
    implicitWidth: 370
    implicitHeight: grid.implicitHeight + Appearance.padding.large * 2

    CalendarGrid {
        id: grid

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Appearance.padding.large
    }
}
