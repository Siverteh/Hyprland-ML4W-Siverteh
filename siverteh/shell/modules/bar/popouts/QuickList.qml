import qs.widgets
import QtQuick
import QtQuick.Controls

Flickable {
    id: root
    property real maximumHeight: 210
    default property alias contents: items.data
    width: parent.width
    height: Math.min(contentHeight, maximumHeight)
    contentWidth: width
    contentHeight: items.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    FastScroll {
        view: root
    }
    ScrollBar.vertical: ScrollBar {}
    Column {
        id: items
        width: root.width
        spacing: 7
    }
}
