import QtQuick
import qs.widgets
import "overview" as Cards
import "overview/overview.js" as Overview

Item {
    id: root
    required property bool shouldUpdate
    readonly property var geometry: Overview.layout(width)
    implicitWidth: 874
    implicitHeight: geometry.height
    Flickable {
        id: scroll
        objectName: "overviewScroll"
        anchors.fill: parent
        contentWidth: width
        contentHeight: root.geometry.height
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        FastScroll {
            view: scroll
        }
        Cards.NacreWeatherCard {
            objectName: "overviewWeather"
            x: root.geometry.weather[0]
            y: root.geometry.weather[1]
            width: root.geometry.weather[2]
            height: root.geometry.weather[3]
        }
        Cards.NacreHostCard {
            objectName: "overviewHost"
            active: root.shouldUpdate && Overview.inViewport(root.geometry.host, scroll.contentY, scroll.height)
            x: root.geometry.host[0]
            y: root.geometry.host[1]
            width: root.geometry.host[2]
            height: root.geometry.host[3]
        }
        Cards.NacreClockCard {
            objectName: "overviewClock"
            x: root.geometry.clock[0]
            y: root.geometry.clock[1]
            width: root.geometry.clock[2]
            height: root.geometry.clock[3]
        }
        Cards.NacreCalendarCard {
            objectName: "overviewCalendar"
            x: root.geometry.calendar[0]
            y: root.geometry.calendar[1]
            width: root.geometry.calendar[2]
            height: root.geometry.calendar[3]
        }
        Cards.NacreResourceCard {
            objectName: "overviewResources"
            x: root.geometry.resources[0]
            y: root.geometry.resources[1]
            width: root.geometry.resources[2]
            height: root.geometry.resources[3]
        }
        Cards.NacreMediaCard {
            objectName: "overviewMedia"
            active: root.shouldUpdate && Overview.inViewport(root.geometry.media, scroll.contentY, scroll.height)
            x: root.geometry.media[0]
            y: root.geometry.media[1]
            width: root.geometry.media[2]
            height: root.geometry.media[3]
        }
    }
}
