import qs.services
import qs.config
import QtQuick

Item {
    id: root
    property bool active: false
    Row {
        anchors.fill: parent
        spacing: 3
        Repeater {
            model: 24
            Rectangle {
                required property int index
                width: Math.max(1, (root.width - 23 * 3) / 24)
                height: root.active ? Math.max(3, Math.min(100, Cava.values[Math.floor(index * Cava.values.length / 24)] ?? 0) / 100 * root.height) : 3
                anchors.verticalCenter: parent.verticalCenter
                radius: width / 2
                color: Colours.palette.m3primary
                Behavior on height {
                    NumberAnimation {
                        duration: 70
                    }
                }
            }
        }
    }
}
