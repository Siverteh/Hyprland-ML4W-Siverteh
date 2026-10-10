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
    readonly property string outline: edge === "top" ? `M0 0 H${width} C${width * .90} 0 ${width * .85} ${height} ${width * .70} ${height} H${width * .30} C${width * .15} ${height} ${width * .10} 0 0 0 Z` : edge === "left" ? `M0 0 H${base} C${width} ${height * .12} ${width} ${height * .20} ${width} ${height * .35} V${height * .65} C${width} ${height * .80} ${width} ${height * .88} ${base} ${height} H0 Z` : `M${width} 0 H${width - base} C0 ${height * .12} 0 ${height * .20} 0 ${height * .35} V${height * .65} C0 ${height * .80} 0 ${height * .88} ${width - base} ${height} H${width} Z`
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: NacreTokens.body
            strokeColor: Qt.alpha(NacreTokens.accent, root.hovered || root.active ? .75 : .35)
            strokeWidth: 0
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
