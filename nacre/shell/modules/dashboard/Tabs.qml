import qs.widgets
import qs.services
import qs.config
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property real nonAnimWidth
    property alias currentIndex: bar.currentIndex
    readonly property TabBar bar: bar

    implicitHeight: bar.implicitHeight + indicator.implicitHeight + indicator.anchors.topMargin + separator.implicitHeight

    TabBar {
        id: bar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        background: null

        Tab {
            iconName: "dashboard"
            text: qsTr("Dashboard")
        }

        Tab {
            iconName: "queue_music"
            text: qsTr("Media")
        }

        Tab {
            iconName: "speed"
            text: qsTr("Performance")
        }

        Tab {
            iconName: "workspaces"
            text: qsTr("Workspaces")
        }
        Tab {
            iconName: "settings"
            text: qsTr("Settings")
        }
    }

    Item {
        id: indicator

        anchors.top: bar.bottom
        anchors.topMargin: NacreDashboard.sizes.tabIndicatorSpacing

        implicitWidth: bar.currentItem.contentItem.implicitWidth
        implicitHeight: NacreDashboard.sizes.tabIndicatorHeight

        x: bar.currentItem.x + (bar.currentItem.width - implicitWidth) / 2

        clip: true

        NacreSurface {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: parent.implicitHeight * 2

            color: Colours.palette.m3primary
            radius: NacreAppearance.rounding.full
        }

        // Selection feedback follows the clicked tab in the same frame.
    }

    NacreSurface {
        id: separator

        anchors.top: indicator.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        implicitHeight: 1
        color: Colours.palette.m3outlineVariant
    }

    component Tab: TabButton {
        id: tab

        required property string iconName
        readonly property bool current: TabBar.tabBar.currentItem === this

        background: null

        contentItem: MouseArea {
            id: mouse

            implicitWidth: Math.max(icon.width, label.width)
            implicitHeight: icon.height + label.height

            cursorShape: Qt.PointingHandCursor

            onPressed: ({
                    x,
                    y
                }) => {
                tab.TabBar.tabBar.setCurrentIndex(tab.TabBar.index);

                const stateY = stateWrapper.y;
                rippleAnim.x = x;
                rippleAnim.y = y - stateY;

                const dist = (ox, oy) => ox * ox + oy * oy;
                const stateEndY = stateY + stateWrapper.height;
                rippleAnim.radius = Math.sqrt(Math.max(dist(0, stateY), dist(0, stateEndY), dist(width, stateY), dist(width, stateEndY)));

                rippleAnim.restart();
            }
            onWheel: event => {
                if (event.angleDelta.y < 0)
                    tab.TabBar.tabBar.incrementCurrentIndex();
                else if (event.angleDelta.y > 0)
                    tab.TabBar.tabBar.decrementCurrentIndex();
            }

            SequentialAnimation {
                id: rippleAnim

                property real x
                property real y
                property real radius

                PropertyAction {
                    target: ripple
                    property: "x"
                    value: rippleAnim.x
                }
                PropertyAction {
                    target: ripple
                    property: "y"
                    value: rippleAnim.y
                }
                PropertyAction {
                    target: ripple
                    property: "opacity"
                    value: 0.1
                }
                ParallelAnimation {
                    Anim {
                        target: ripple
                        properties: "implicitWidth,implicitHeight"
                        from: 0
                        to: rippleAnim.radius * 2
                        duration: NacreAppearance.anim.durations.large
                        easing.bezierCurve: NacreAppearance.anim.curves.standardDecel
                    }
                    Anim {
                        target: ripple
                        property: "opacity"
                        to: 0
                        duration: NacreAppearance.anim.durations.large
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: NacreAppearance.anim.curves.standardDecel
                    }
                }
            }

            ClippingRectangle {
                id: stateWrapper

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: parent.height + NacreDashboard.sizes.tabIndicatorSpacing * 2

                color: "transparent"
                radius: NacreAppearance.rounding.small

                NacreSurface {
                    id: stateLayer

                    anchors.fill: parent

                    color: tab.current ? Colours.palette.m3primary : Colours.palette.m3onSurface
                    opacity: mouse.pressed ? 0.1 : tab.hovered ? 0.08 : 0

                    Behavior on opacity {
                        Anim {}
                    }
                }

                NacreSurface {
                    id: ripple

                    radius: NacreAppearance.rounding.full
                    color: tab.current ? Colours.palette.m3primary : Colours.palette.m3onSurface
                    opacity: 0

                    transform: Translate {
                        x: -ripple.width / 2
                        y: -ripple.height / 2
                    }
                }
            }

            NacreIcon {
                id: icon

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: label.top

                text: tab.iconName
                color: tab.current ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                fill: tab.current ? 1 : 0
                font.pointSize: NacreAppearance.font.size.large

                Behavior on fill {
                    NumberAnimation {
                        duration: NacreAppearance.anim.durations.normal
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: NacreAppearance.anim.curves.standard
                    }
                }
            }

            NacreText {
                id: label

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                text: tab.text
                font.pointSize: 11
                color: tab.current ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
            }
        }
    }

    component Anim: NumberAnimation {
        duration: NacreAppearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: NacreAppearance.anim.curves.standard
    }
}
