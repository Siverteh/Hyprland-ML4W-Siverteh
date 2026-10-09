import QtQuick
import qs.widgets
import qs.services

Item {
    id: root
    property int currentIndex: 0
    signal selected(int index)
    readonly property var pages: [
        {
            label: "Dashboard",
            icon: "dashboard"
        },
        {
            label: "Media",
            icon: "queue_music"
        },
        {
            label: "Performance",
            icon: "speed"
        },
        {
            label: "Workspaces",
            icon: "workspaces"
        },
        {
            label: "Settings",
            icon: "settings"
        }
    ]
    implicitHeight: 72
    Row {
        anchors.fill: parent
        Repeater {
            model: root.pages
            delegate: NacreSurface {
                required property var modelData
                required property int index
                objectName: "dashboardTab" + index
                width: root.width / root.pages.length
                height: root.height
                color: "transparent"
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    NacreIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: parent.parent.modelData.icon
                        font.pointSize: 19
                        color: root.currentIndex === parent.parent.index ? NacreColours.palette.m3primary : NacreColours.palette.m3onSurfaceVariant
                    }
                    NacreText {
                        text: parent.parent.modelData.label
                        font.pointSize: 11
                        color: root.currentIndex === parent.parent.index ? NacreColours.palette.m3primary : NacreColours.palette.m3onSurfaceVariant
                    }
                }
                NacreInteraction {
                    accessibleName: parent.modelData.label
                    function onClicked() {
                        root.selected(parent.index);
                    }
                }
            }
        }
    }
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: NacreColours.palette.m3outlineVariant
    }
    Rectangle {
        objectName: "dashboardSelection"
        y: parent.height - 2
        x: root.currentIndex * root.width / root.pages.length + 16
        width: Math.max(0, root.width / root.pages.length - 32)
        height: 2
        color: NacreColours.palette.m3primary
    }
}
