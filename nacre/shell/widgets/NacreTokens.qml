pragma Singleton

import QtQuick
import qs.services

QtObject {
    id: root

    property string textFamily: "IBM Plex Sans"
    property string monoFamily: "JetBrains Mono NF"
    property real textPointSize: 12
    property real cornerRadius: 12
    property real spacing: 8
    property int colorDuration: 200
    property int stateDuration: 120
    property int textDuration: 400
    property bool reduceMotion: DesktopSettings.data.reduceMotion === true
    readonly property bool motionEnabled: !reduceMotion && DesktopSettings.data.animations !== false

    readonly property color body: Colours.palette.m3surface
    readonly property color raised: Colours.palette.m3surfaceContainer
    readonly property color frame: Colours.palette.m3frame
    readonly property color ink: Colours.palette.m3onSurface
    readonly property color mutedInk: Colours.palette.m3onSurfaceVariant
    readonly property color accent: Colours.palette.m3primary
    readonly property color outline: Colours.palette.m3outline

    readonly property bool light: Colours.light
    property bool paletteSwitch: false
    readonly property bool colorMotionAllowed: motionEnabled && !paletteSwitch
    onLightChanged: {
        // Light/dark foreground and surface changes must remain readable together.
        paletteSwitch = true;
        Qt.callLater(() => paletteSwitch = false);
    }

    function focusInk(background): color {
        function linear(channel) {
            return channel <= 0.04045 ? channel / 12.92 : Math.pow((channel + 0.055) / 1.055, 2.4);
        }
        const c = background ?? root.raised;
        const luminance = linear(c.r) * 0.2126 + linear(c.g) * 0.7152 + linear(c.b) * 0.0722;
        return luminance > 0.179 ? "#101014" : "#ffffff";
    }
}
