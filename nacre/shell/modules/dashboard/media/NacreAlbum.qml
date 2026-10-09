import QtQuick
import QtQuick.Shapes
import qs.widgets

Item {
    id: root
    property string source: ""
    property real progress: 0
    property bool ready: false
    implicitWidth: 224
    implicitHeight: 224
    NacreClip {
        id: mask
        anchors.fill: parent
        anchors.margins: 8
        radius: width / 2
        color: NacreTokens.raised
        Image {
            id: picture
            objectName: "fullAlbumImage"
            anchors.fill: parent
            source: root.source
            asynchronous: true
            cache: true
            retainWhileLoading: true
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: 480
            sourceSize.height: 480
            visible: status === Image.Ready || status === Image.Loading && root.ready
            onStatusChanged: if (status === Image.Ready)
                root.ready = true
            else if (status === Image.Error || status === Image.Null)
                root.ready = false
        }
        NacreIcon {
            anchors.centerIn: parent
            text: "music_note"
            font.pointSize: 44
            visible: !picture.visible
            color: NacreTokens.mutedInk
        }
    }
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: "transparent"
            strokeColor: NacreTokens.accent
            strokeWidth: 5
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - 3
                radiusY: root.height / 2 - 3
                startAngle: -90
                sweepAngle: root.progress * 360
            }
        }
    }
}
