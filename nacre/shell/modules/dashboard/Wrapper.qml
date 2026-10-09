import QtQuick
import Quickshell
import qs.config

Item {
    id: root

    required property PersistentProperties visibilities

    clip: true
    visible: height > 0
    implicitHeight: 0
    implicitWidth: content.implicitWidth
    transitions: [
        Transition {
            from: ""
            to: "visible"

            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: NacreAppearance.anim.durations.expressiveDefaultSpatial
                easing.type: Easing.BezierSpline
                easing.bezierCurve: NacreAppearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: NacreAppearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: NacreAppearance.anim.curves.emphasized
            }
        }
    ]

    Content {
        id: content

        visibilities: root.visibilities
    }

    states: State {
        name: "visible"
        when: root.visibilities.dashboard

        PropertyChanges {
            root.implicitHeight: content.implicitHeight
        }
    }
}
