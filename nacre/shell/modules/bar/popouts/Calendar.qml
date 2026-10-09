import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.widgets

Column {
    id: root

    property int month: NacreTime.date.getMonth()
    property int year: NacreTime.date.getFullYear()

    function changeMonth(delta) {
        const date = new Date(year, month + delta, 1);
        month = date.getMonth();
        year = date.getFullYear();
    }

    width: 340
    spacing: NacreAppearance.spacing.normal

    RowLayout {
        width: 340
        height: 34

        NacreIcon {
            text: "chevron_left"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.changeMonth(-1)
            }
        }

        NacreText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM yyyy")
            font.weight: 500
        }

        NacreIcon {
            text: "chevron_right"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.changeMonth(1)
            }
        }
    }

    CalendarGrid {
        width: 340
        month: root.month
        year: root.year
    }
}
