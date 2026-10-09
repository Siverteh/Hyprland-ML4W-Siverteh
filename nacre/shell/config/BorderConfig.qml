pragma Singleton
import QtQuick
import Quickshell
import qs.services

Singleton {
    id: root

    readonly property color colour: Colours.palette.m3frame
    readonly property int headerHeight: DesktopSettings.data.topEdge === false ? 0 : 40 + thickness
    readonly property int thickness: DesktopSettings.data.frameWidth ?? 10
    readonly property int left: DesktopSettings.data.leftEdge === false ? 0 : thickness
    readonly property int right: DesktopSettings.data.rightEdge === false ? 0 : thickness
    readonly property int bottom: DesktopSettings.data.bottomEdge === false ? 0 : thickness
    readonly property int rounding: DesktopSettings.data.frameRounding ?? 25
}
