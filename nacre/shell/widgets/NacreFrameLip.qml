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
    readonly property string outline: edge === "top" ? `M0 0 H${width} C${width * .78} 0 ${width * .78} ${height - 1} ${width / 2} ${height - 1} C${width * .22} ${height - 1} ${width * .22} 0 0 0 Z` : edge === "left" ? `M0 0 H${base} C${width - 1} ${height * .2} ${width - 1} ${height * .8} ${base} ${height} H0 Z` : `M${width} 0 H${width - base} C1 ${height * .2} 1 ${height * .8} ${width - base} ${height} H${width} Z`
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: NacreTokens.body
            strokeColor: Qt.alpha(NacreTokens.accent, root.hovered || root.active ? .75 : .35)
            strokeWidth: 1
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
