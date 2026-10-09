import QtQuick
import qs.config
import qs.services
import qs.utils
import qs.widgets

Item {
    id: root

    anchors.centerIn: parent
    implicitWidth: icon.implicitWidth + info.implicitWidth + info.anchors.leftMargin
    onVisibleChanged: {
        if (visible)
            Weather.reload();
    }

    NacreIcon {
        id: icon

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        animate: true
        text: Weather.icon || "cloud_alert"
        color: Colours.palette.m3secondary
        font.pointSize: NacreAppearance.font.size.extraLarge * 2
        font.variableAxes: ({
                "opsz": NacreAppearance.font.size.extraLarge * 1.2
            })
    }

    Column {
        id: info

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: icon.right
        anchors.leftMargin: NacreAppearance.spacing.large
        spacing: NacreAppearance.spacing.small

        NacreText {
            anchors.horizontalCenter: parent.horizontalCenter
            animate: true
            text: Weather.displayTemperature
            color: Colours.palette.m3primary
            font.pointSize: NacreAppearance.font.size.extraLarge
            font.weight: 500
        }

        NacreText {
            anchors.horizontalCenter: parent.horizontalCenter
            animate: true
            text: Weather.description || qsTr("No weather")
            elide: Text.ElideRight
            width: Math.min(implicitWidth, root.parent.width - icon.implicitWidth - info.anchors.leftMargin - NacreAppearance.padding.large * 2)
        }
    }
}
