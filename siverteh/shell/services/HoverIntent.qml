pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    readonly property int edgeWidth: 3
    property var positions: ({})
    property var blocked: ({})
    property var headers: ({})
    property var popupHovered: ({})

    function fullscreenFor(name) {
        return Hyprland.focusedMonitor?.name === name && Hyprland.activeClient?.lastIpcObject?.fullscreen === 2;
    }
    function canAuto(screen, buttons) {
        return buttons === Qt.NoButton && !fullscreenFor(screen.name);
    }
    function observe(screen, x, y) {
        positions[screen.name] = {x:x, y:y, width:screen.width, height:screen.height};
        const b = blocked[screen.name];
        if (!b) return;
        if (y > edgeWidth || x < screen.width / 2 - 350 || x > screen.width / 2 + 350) b.dashboard = false;
        if (x >= edgeWidth) b.left = false;
        if (x < screen.width - edgeWidth) b.osd = false;
    }
    function canOpen(name, screen, buttons) {
        return canAuto(screen, buttons) && !blocked[screen.name]?.[name];
    }
    function rearm(name, screen) {
        if (blocked[screen.name]) blocked[screen.name][name] = false;
    }
    function dismiss(screen) {
        const p = positions[screen.name];
        blocked[screen.name] = {
            dashboard: !!p && p.y <= edgeWidth && Math.abs(p.x - p.width / 2) <= Math.min(350, p.width * 0.225),
            left: !!p && p.x < edgeWidth,
            osd: !!p && p.x >= p.width - edgeWidth,
            popouts: popupHovered[screen.name] === true
        };
    }
}
