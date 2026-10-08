import QtQuick
import QtQuick.Controls
import qs.config
import qs.services

Item {
    id: root

    property int month: Time.date.getMonth()
    property int year: Time.date.getFullYear()
    readonly property int cellHeight: 38
    readonly property int cellGap: 4

    implicitWidth: 340
    implicitHeight: days.height + 10 + dates.height

    DayOfWeekRow {
        id: days

        width: parent.width
        height: 30
        spacing: root.cellGap
        topPadding: 0
        bottomPadding: 0

        delegate: StyledText {
            required property var model

            width: (days.width - days.spacing * 6) / 7
            height: 30
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: model.shortName
            font.weight: 500
            font.pointSize: 11
            color: Colours.palette.m3onSurfaceVariant
        }
    }

    MonthGrid {
        id: dates

        anchors.top: days.bottom
        anchors.topMargin: 10
        width: parent.width
        height: root.cellHeight * 6 + spacing * 5
        month: root.month
        year: root.year
        spacing: root.cellGap

        delegate: Item {
            id: day

            required property var model

            width: (dates.width - dates.spacing * 6) / 7
            height: root.cellHeight

            StyledRect {
                width: Math.min(32, parent.width - 4)
                height: width
                radius: width / 2
                anchors.centerIn: parent
                color: day.model.today ? Colours.palette.m3primary : "transparent"

                StyledText {
                    anchors.centerIn: parent
                    text: day.model.day
                    font.pointSize: 12
                    color: day.model.today ? Colours.palette.m3onPrimary : day.model.month === dates.month ? Colours.palette.m3onSurface : Colours.palette.m3outline
                }
            }
        }
    }
}
