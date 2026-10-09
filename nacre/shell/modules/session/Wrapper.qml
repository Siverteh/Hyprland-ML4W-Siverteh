import QtQuick
import Quickshell
import qs.config
import qs.services

Item {
    id: root

    required property PersistentProperties visibilities

    visible: width > 0
    implicitWidth: 0
    implicitHeight: content.implicitHeight
    transitions: [
        Transition {
            from: ""
            to: "visible"

            NumberAnimation {
                target: root
                property: "implicitWidth"
                duration: NacreAppearance.anim.durations.expressiveFastSpatial
                easing.type: Easing.BezierSpline
                easing.bezierCurve: NacreAppearance.anim.curves.expressiveFastSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            NumberAnimation {
                target: root
                property: "implicitWidth"
                duration: root.visibilities.osd ? NacreAppearance.anim.durations.expressiveFastSpatial : NacreAppearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.visibilities.osd ? NacreAppearance.anim.curves.expressiveFastSpatial : NacreAppearance.anim.curves.emphasized
            }
        }
    ]

    Content {
        id: content

        visibilities: root.visibilities
    }

    states: State {
        name: "visible"
        when: root.visibilities.session

        PropertyChanges {
            root.implicitWidth: content.implicitWidth
        }
    }
}
