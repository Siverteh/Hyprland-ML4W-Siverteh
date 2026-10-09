import QtQuick
import qs.widgets
import qs.services
import "overview.js" as Overview

NacreOverviewCard {
    id: root
    readonly property var gauges: [
        {
            label: "CPU",
            icon: "memory",
            value: SystemUsage.cpuPerc,
            color: Colours.palette.m3primary
        },
        {
            label: "Memory",
            icon: "memory",
            value: SystemUsage.memPerc,
            color: Colours.palette.m3secondary
        },
        {
            label: "Storage",
            icon: "hard_drive",
            value: SystemUsage.storagePerc,
            color: Colours.palette.m3tertiary
        }
    ]
    Row {
        x: 14
        y: 16
        width: parent.width - 28
        height: parent.height - 32
        spacing: 10
        Repeater {
            model: root.gauges
            delegate: Item {
                required property var modelData
                width: Math.max(1, (parent.width - 20) / 3)
                height: parent.height
                Accessible.role: Accessible.ProgressBar
                Accessible.name: modelData.label + " " + Overview.percent(modelData.value)
                NacreSurface {
                    x: (parent.width - width) / 2
                    width: Math.min(11, parent.width)
                    height: parent.height - 28
                    radius: width / 2
                    color: Colours.palette.m3surfaceContainerHigh
                    NacreSurface {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Overview.fraction(modelData.value) * parent.height
                        radius: width / 2
                        color: modelData.color
                    }
                }
                NacreIcon {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: parent.modelData.icon
                    color: parent.modelData.color
                    font.pointSize: 13
                }
            }
        }
    }
}
