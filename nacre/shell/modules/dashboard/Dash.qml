import QtQuick.Layouts
import "dash" as Cards
import qs.config
import qs.services
import qs.widgets

GridLayout {
    id: root

    required property bool shouldUpdate

    rowSpacing: NacreAppearance.spacing.normal
    columnSpacing: NacreAppearance.spacing.normal

    Rect {
        Layout.column: 2
        Layout.columnSpan: 3
        Layout.preferredWidth: user.implicitWidth
        Layout.preferredHeight: user.implicitHeight

        Cards.User {
            id: user
        }
    }

    Rect {
        Layout.row: 0
        Layout.columnSpan: 2
        Layout.preferredWidth: NacreDashboard.sizes.weatherWidth
        Layout.fillHeight: true

        Cards.Weather {}
    }

    Rect {
        Layout.row: 1
        Layout.preferredWidth: dateTime.implicitWidth
        Layout.fillHeight: true

        Cards.DateTime {
            id: dateTime
        }
    }

    Rect {
        Layout.row: 1
        Layout.column: 1
        Layout.columnSpan: 3
        Layout.fillWidth: true
        Layout.preferredHeight: calendar.implicitHeight

        Cards.Calendar {
            id: calendar
        }
    }

    Rect {
        Layout.row: 1
        Layout.column: 4
        Layout.preferredWidth: resources.implicitWidth
        Layout.fillHeight: true

        Cards.Resources {
            id: resources
        }
    }

    Rect {
        Layout.row: 0
        Layout.column: 5
        Layout.rowSpan: 2
        Layout.preferredWidth: media.implicitWidth
        Layout.fillHeight: true

        Cards.Media {
            id: media

            shouldUpdate: root.shouldUpdate
        }
    }

    component Rect: NacreSurface {
        radius: NacreAppearance.rounding.small
        color: Colours.palette.m3surfaceContainer
    }
}
