pragma ComponentBehavior: Bound

import qs.widgets
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property PersistentProperties visibilities
    required property TextField search
    required property int padding
    required property int rounding

    property bool showWallpapers: search.text.startsWith(`${NacreLauncher.actionPrefix}wallpaper `)
    property var currentList: (showWallpapers ? wallpaperList : appList).item

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom

    clip: true
    state: showWallpapers ? "wallpapers" : "apps"

    states: [
        State {
            name: "apps"

            PropertyChanges {
                root.implicitWidth: NacreLauncher.sizes.itemWidth
                root.implicitHeight: Math.max(empty.height, appList.height)
                appList.active: true
            }

            AnchorChanges {
                anchors.left: root.parent.left
                anchors.right: root.parent.right
            }
        },
        State {
            name: "wallpapers"

            PropertyChanges {
                root.implicitWidth: Math.max(NacreLauncher.sizes.itemWidth, wallpaperList.width)
                root.implicitHeight: NacreLauncher.sizes.wallpaperHeight
                wallpaperList.active: true
            }
        }
    ]

    transitions: Transition {
        SequentialAnimation {
            NumberAnimation {
                target: root
                property: "opacity"
                from: 1
                to: 0
                duration: NacreAppearance.anim.durations.small
                easing.type: Easing.BezierSpline
                easing.bezierCurve: NacreAppearance.anim.curves.standard
            }
            PropertyAction {
                targets: [appList, wallpaperList]
                properties: "active"
            }
            ParallelAnimation {
                NumberAnimation {
                    target: root
                    properties: "implicitWidth,implicitHeight"
                    duration: NacreAppearance.anim.durations.large
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: NacreAppearance.anim.curves.emphasized
                }
                NumberAnimation {
                    target: root
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: NacreAppearance.anim.durations.large
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: NacreAppearance.anim.curves.standard
                }
            }
        }
    }

    Loader {
        id: appList

        active: false
        asynchronous: true

        anchors.left: parent.left
        anchors.right: parent.right

        sourceComponent: AppList {
            padding: root.padding
            search: root.search
            visibilities: root.visibilities
        }
    }

    Loader {
        id: wallpaperList

        active: false
        asynchronous: true

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        sourceComponent: WallpaperList {
            filter: root.search.text.split(" ").slice(1).join(" ")
            visibilities: root.visibilities
        }
    }

    Item {
        id: empty

        opacity: root.currentList?.count === 0 ? 1 : 0
        scale: root.currentList?.count === 0 ? 1 : 0.5

        implicitWidth: icon.width + text.width + NacreAppearance.spacing.small
        implicitHeight: icon.height

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        NacreIcon {
            id: icon

            text: "manage_search"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: NacreAppearance.font.size.extraLarge

            anchors.verticalCenter: parent.verticalCenter
        }

        NacreText {
            id: text

            anchors.left: icon.right
            anchors.leftMargin: NacreAppearance.spacing.small
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("No results")
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: NacreAppearance.font.size.larger
            font.weight: 500
        }

        Behavior on opacity {
            NumberAnimation {
                duration: NacreAppearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: NacreAppearance.anim.curves.standard
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: NacreAppearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: NacreAppearance.anim.curves.standard
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: NacreAppearance.anim.durations.large
            easing.type: Easing.BezierSpline
            easing.bezierCurve: NacreAppearance.anim.curves.emphasizedDecel
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: NacreAppearance.anim.durations.large
            easing.type: Easing.BezierSpline
            easing.bezierCurve: NacreAppearance.anim.curves.emphasizedDecel
        }
    }
}
