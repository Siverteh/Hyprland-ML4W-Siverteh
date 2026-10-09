pragma Singleton
import QtQuick

QtObject {
    readonly property var colour: NacreFrame.colour
    readonly property var thickness: NacreFrame.thickness
    readonly property var headerHeight: NacreFrame.headerHeight
    readonly property var left: NacreFrame.left
    readonly property var right: NacreFrame.right
    readonly property var bottom: NacreFrame.bottom
    readonly property var rounding: NacreFrame.rounding
}
