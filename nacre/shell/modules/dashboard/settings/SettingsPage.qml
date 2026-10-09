import QtQuick
import QtQuick.Controls
import qs.widgets

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

    Column {
        id: stack

        width: parent.width
        spacing: 14
    }

    ScrollBar.vertical: ScrollBar {}
}
