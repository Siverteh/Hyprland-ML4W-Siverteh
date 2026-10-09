import QtQuick
import QtQuick.Controls
import qs.config
import qs.services
import qs.widgets

Row {
    id: root

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    padding: NacreAppearance.padding.large
    spacing: NacreAppearance.spacing.normal

    Resource {
        icon: "memory"
        value: SystemUsage.cpuPerc
        colour: Colours.palette.m3primary
    }

    Resource {
        icon: "memory_alt"
        value: SystemUsage.memPerc
        colour: Colours.palette.m3secondary
    }

    Resource {
        icon: "hard_disk"
        value: SystemUsage.storagePerc
        colour: Colours.palette.m3tertiary
    }

    component Resource: Item {
        id: res

        required property string icon
        required property real value
        required property color colour

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: NacreAppearance.padding.large
        implicitWidth: icon.implicitWidth

        NacreSurface {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: icon.top
            anchors.bottomMargin: NacreAppearance.spacing.small
            implicitWidth: NacreDashboard.sizes.resourceProgessThickness
            color: Colours.palette.m3surfaceContainerHigh
            radius: NacreAppearance.rounding.full

            NacreSurface {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                implicitHeight: res.value * parent.height
                color: res.colour
                radius: NacreAppearance.rounding.full
            }
        }

        NacreIcon {
            id: icon

            anchors.bottom: parent.bottom
            text: res.icon
            color: res.colour
        }

        Behavior on value {
            NumberAnimation {
                duration: NacreAppearance.anim.durations.large
                easing.type: Easing.BezierSpline
                easing.bezierCurve: NacreAppearance.anim.curves.standard
            }
        }
    }
}
