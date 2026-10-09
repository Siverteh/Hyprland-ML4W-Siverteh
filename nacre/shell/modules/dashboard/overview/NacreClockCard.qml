import QtQuick
import qs.widgets
import qs.services

NacreOverviewCard {
    id: root
    Accessible.role: Accessible.StaticText
    Accessible.name: Time.format("dddd, d MMMM HH:mm")
    Column {
        anchors.centerIn: parent
        spacing: 3
        NacreText {
            objectName: "clockHour"
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.format("HH")
            color: Colours.palette.m3secondary
            font.pointSize: root.height < 200 ? 24 : 31
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            Repeater {
                model: 3
                Rectangle {
                    width: 5
                    height: 5
                    radius: 2.5
                    color: Colours.palette.m3primary
                }
            }
        }
        NacreText {
            objectName: "clockMinute"
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.format("mm")
            color: Colours.palette.m3secondary
            font.pointSize: root.height < 200 ? 24 : 31
        }
        NacreText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.format("ddd, d")
            color: Colours.palette.m3tertiary
            font.pointSize: 10
        }
    }
}
