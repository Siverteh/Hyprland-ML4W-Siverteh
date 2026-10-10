import QtQuick
import QtQuick.Shapes

Item {
    id: root
    required property string edge
    property real base: 10
    property bool active: false
    property alias hovered: pointer.containsMouse
    readonly property real pointerX: pointer.mouseX
    readonly property real pointerY: pointer.mouseY
    signal entered(int buttons)
    signal moved(int buttons)
    signal exited
    signal clicked
    property real accentStrength: hovered || active ? 1 : .85
    Behavior on accentStrength {
        NumberAnimation {
            duration: NacreTokens.motionEnabled ? 120 : 0
        }
    }
    readonly property color tipColor: Qt.tint(NacreTokens.body, Qt.alpha(NacreTokens.accent, accentStrength))
    readonly property string outline: edge === "top" ? `M0 0 H${width} C${width * .8} 0 ${width * .8} ${height} ${width / 2} ${height} C${width * .2} ${height} ${width * .2} 0 0 0 Z` : edge === "left" ? `M0 0 H${base} C${width} ${height * .2} ${width} ${height * .8} ${base} ${height} H0 Z` : `M${width} 0 H${width - base} C0 ${height * .2} 0 ${height * .8} ${width - base} ${height} H${width} Z`
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: 0
            fillGradient: LinearGradient {
                x1: root.edge === "top" ? root.width / 2 : root.edge === "left" ? root.base : root.width - root.base
                y1: root.edge === "top" ? 0 : root.height / 2
                x2: root.edge === "top" ? root.width / 2 : root.edge === "left" ? root.base + (root.width - root.base) * .75 : (root.width - root.base) * .25
                y2: root.edge === "top" ? root.height : root.height / 2
                GradientStop {
                    position: 0
                    color: NacreTokens.body
                }
                GradientStop {
                    position: 1
                    color: root.tipColor
                }
            }
            PathSvg {
                path: root.outline
            }
        }
    }
    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onEntered: root.entered(pressedButtons)
        onPositionChanged: event => root.moved(event.buttons)
        onExited: root.exited()
        onClicked: root.clicked()
    }
    Accessible.role: Accessible.Button
    Accessible.name: edge === "top" ? "Open dashboard" : edge === "left" ? "Open assistant" : "Open control center"
    Accessible.onPressAction: clicked()
}
