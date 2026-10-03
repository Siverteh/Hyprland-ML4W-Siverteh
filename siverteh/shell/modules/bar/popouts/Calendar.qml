import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick
import QtQuick.Layouts
Column {
    id:root
    width:340
    spacing:Appearance.spacing.normal
    property int month:Time.date.getMonth()
    property int year:Time.date.getFullYear()
    function changeMonth(delta) {const date=new Date(year,month+delta,1);month=date.getMonth();year=date.getFullYear();}
    RowLayout {
        width:340;height:34
        MaterialIcon {text:"chevron_left";MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.changeMonth(-1)}}
        StyledText {Layout.fillWidth:true;horizontalAlignment:Text.AlignHCenter;text:Qt.formatDate(new Date(root.year,root.month,1),"MMMM yyyy");font.weight:500}
        MaterialIcon {text:"chevron_right";MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:root.changeMonth(1)}}
    }
    CalendarGrid {width:340;month:root.month;year:root.year}
}
