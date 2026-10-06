import qs.widgets
import QtQuick
import QtQuick.Controls

Flickable {
    id: root
    default property alias contents: stack.data
    contentWidth: width
    contentHeight: stack.implicitHeight + 8
    clip: true
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds
    FastScroll {
        view: root
    }
    ScrollBar.vertical: ScrollBar {}
    Column {
        id: stack
        width: parent.width
        spacing: 14
    }
}
