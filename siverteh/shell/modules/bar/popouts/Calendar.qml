import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick
import QtQuick.Controls

Column {
    id:root
    width:300
    spacing:Appearance.spacing.small
    property int month: Time.date.getMonth()
    property int year: Time.date.getFullYear()
    function changeMonth(delta) {
        const d=new Date(year,month+delta,1);
        month=d.getMonth();year=d.getFullYear();
    }
    Row {
        width:parent.width
        spacing:Appearance.spacing.small
        MaterialIcon {text:"chevron_left";MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.changeMonth(-1)}}
        StyledText {
            width:root.width-60
            horizontalAlignment:Text.AlignHCenter
            text:Qt.formatDate(new Date(root.year,root.month,1),"MMMM yyyy")
            font.weight:500
        }
        MaterialIcon {text:"chevron_right";MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.changeMonth(1)}}
    }
    DayOfWeekRow {
        width:parent.width
        delegate:StyledText {required property var model;text:model.shortName;horizontalAlignment:Text.AlignHCenter;color:Colours.palette.m3onSurfaceVariant}
    }
    MonthGrid {
        id:grid
        width:parent.width
        height:34*6 + spacing*5
        month:root.month;year:root.year
        spacing:3
        delegate:Item {
            id:day
            required property var model
            implicitWidth:(grid.width-grid.spacing*6)/7
            implicitHeight:34
            StyledRect {
                width:30;height:30;anchors.centerIn:parent;radius:15
                color:day.model.today?Colours.palette.m3primary:"transparent"
                StyledText {
                    anchors.centerIn:parent
                    text:grid.locale.toString(day.model.date,"d")
                    color:day.model.today?Colours.palette.m3onPrimary:day.model.month===grid.month?Colours.palette.m3onSurface:Colours.palette.m3outline
                }
            }
        }
    }
}
