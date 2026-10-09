import qs.widgets
import qs.services
import qs.config
import Quickshell
import Quickshell.Widgets
import QtQuick

Item {
    id: root

    readonly property int padding: NacreAppearance.padding.large

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    implicitWidth: NacreNotifications.sizes.width + padding * 2
    implicitHeight: {
        const count = list.count;
        if (count === 0)
            return 0;

        let height = (count - 1) * NacreAppearance.spacing.smaller;
        for (let i = 0; i < count; i++)
            height += list.itemAtIndex(i)?.nonAnimHeight ?? 0;

        const screen = QsWindow.window?.screen;
        const visibilities = Visibilities.screens[screen?.name];
        const panel = Visibilities.panels[screen?.name];
        if (visibilities && panel) {
            if (visibilities.osd) {
                const h = panel.osd.y - NacreFrame.rounding * 2;
                if (height > h)
                    height = h;
            }

            if (visibilities.session) {
                const h = panel.session.y - NacreFrame.rounding * 2;
                if (height > h)
                    height = h;
            }
        }

        return Math.min((screen?.height ?? 0) - NacreFrame.thickness * 2, height + padding * 2);
    }

    ClippingWrapperRectangle {
        anchors.fill: parent
        anchors.margins: root.padding

        color: "transparent"
        radius: NacreAppearance.rounding.normal

        ListView {
            id: list
            FastScroll {
                view: list
            }

            model: ScriptModel {
                values: [...Notifs.popups].reverse()
            }

            anchors.fill: parent

            orientation: Qt.Vertical
            spacing: 0
            cacheBuffer: QsWindow.window?.screen.height ?? 0

            delegate: Item {
                id: wrapper

                required property Notifs.Notif modelData
                required property int index
                readonly property alias nonAnimHeight: notif.nonAnimHeight
                property int idx

                onIndexChanged: {
                    if (index !== -1)
                        idx = index;
                }

                implicitWidth: notif.implicitWidth
                implicitHeight: notif.implicitHeight + (idx === 0 ? 0 : NacreAppearance.spacing.smaller)

                ListView.onRemove: removeAnim.start()

                SequentialAnimation {
                    id: removeAnim

                    PropertyAction {
                        target: wrapper
                        property: "ListView.delayRemove"
                        value: true
                    }
                    PropertyAction {
                        target: wrapper
                        property: "enabled"
                        value: false
                    }
                    PropertyAction {
                        target: wrapper
                        property: "implicitHeight"
                        value: 0
                    }
                    PropertyAction {
                        target: wrapper
                        property: "z"
                        value: 1
                    }
                    Anim {
                        target: notif
                        property: "x"
                        to: (notif.x >= 0 ? NacreNotifications.sizes.width : -NacreNotifications.sizes.width) * 2
                        duration: NacreAppearance.anim.durations.normal
                        easing.bezierCurve: NacreAppearance.anim.curves.emphasized
                    }
                    PropertyAction {
                        target: wrapper
                        property: "ListView.delayRemove"
                        value: false
                    }
                }

                ClippingRectangle {
                    anchors.top: parent.top
                    anchors.topMargin: wrapper.idx === 0 ? 0 : NacreAppearance.spacing.smaller

                    color: "transparent"
                    radius: notif.radius
                    implicitWidth: notif.implicitWidth
                    implicitHeight: notif.implicitHeight

                    Notification {
                        id: notif

                        modelData: wrapper.modelData
                    }
                }
            }

            move: Transition {
                Anim {
                    property: "y"
                }
            }

            displaced: Transition {
                Anim {
                    property: "y"
                }
            }
        }
    }

    Behavior on implicitHeight {
        Anim {}
    }

    component Anim: NumberAnimation {
        duration: NacreAppearance.anim.durations.expressiveDefaultSpatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: NacreAppearance.anim.curves.expressiveDefaultSpatial
    }
}
