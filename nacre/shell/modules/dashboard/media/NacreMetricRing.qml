import QtQuick
import QtQuick.Shapes
import qs.widgets
import qs.services
import "media.js" as Model

Item {
    id: root
    required property string valueText
    required property string label
    property real firstValue: NaN
    property real secondValue: NaN
    property string detail: ""
    property string detailLabel: ""
    readonly property real diameter: Math.min(width - 20, height - 50, 224)
    Shape {
        x: (root.width - width) / 2
        y: 6
        width: root.diameter
        height: width
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: "transparent"
            strokeColor: Colours.palette.m3surfaceContainerHigh
            strokeWidth: 8
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.diameter / 2
                centerY: root.diameter / 2
                radiusX: root.diameter / 2 - 8
                radiusY: radiusX
                startAngle: 140
                sweepAngle: 260
            }
        }
        ShapePath {
            fillColor: "transparent"
            strokeColor: Colours.palette.m3primary
            strokeWidth: 8
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.diameter / 2
                centerY: root.diameter / 2
                radiusX: root.diameter / 2 - 8
                radiusY: radiusX
                startAngle: 140
                sweepAngle: Model.fraction(root.firstValue) * 260
            }
        }
        ShapePath {
            fillColor: "transparent"
            strokeColor: Colours.palette.m3secondary
            strokeWidth: 5
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.diameter / 2
                centerY: root.diameter / 2
                radiusX: root.diameter / 2 - 21
                radiusY: radiusX
                startAngle: 140
                sweepAngle: Model.fraction(root.secondValue) * 260
            }
        }
    }
    Column {
        x: 12
        y: root.diameter * .35
        width: parent.width - 24
        spacing: 6
        NacreText {
            width: parent.width
            text: root.valueText
            font.pointSize: 27
            fontSizeMode: Text.Fit
            minimumPointSize: 12
            horizontalAlignment: Text.AlignHCenter
        }
        NacreText {
            width: parent.width
            text: root.label
            color: NacreTokens.mutedInk
            font.pointSize: 11
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }
    NacreText {
        x: 8
        y: root.diameter + 16
        width: parent.width - 16
        text: root.detail + (root.detailLabel ? " · " + root.detailLabel : "")
        font.pointSize: 10
        color: NacreTokens.mutedInk
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }
}
