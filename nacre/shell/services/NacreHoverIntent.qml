pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    readonly property int edgeWidth: 3
    readonly property int dashboardDepth: Math.max(edgeWidth, Math.floor((40 + (DesktopSettings.data.frameWidth ?? 10)) / 2))
    property var positions: ({})
    property var blocked: ({})
    property var headers: ({})
    property var popupHovered: ({})
    property var popupRegions: ({})
    property var owners: ({})
    function validScreen(screen) {
        return !!screen && typeof screen.name === "string" && screen.name.length > 0;
    }
    function titleContains(point) {
        return !!point && point.y >= 0 && point.y <= dashboardDepth && Math.abs(point.x - point.width / 2) <= Math.min(350, point.width * .225);
    }
    function fullscreenFor(name) {
        return NacreHyprland.focusedMonitor?.name === name && Number(NacreHyprland.activeClient?.lastIpcObject?.fullscreen) === 2;
    }
    function canAuto(screen, buttons) {
        return validScreen(screen) && buttons === Qt.NoButton && !fullscreenFor(screen.name);
    }
    function canOpen(name, screen, buttons) {
        return ["dashboard", "left", "osd", "popouts"].includes(name) && canAuto(screen, buttons) && !blocked[screen.name]?.[name];
    }
    function observe(screen, x, y) {
        if (!validScreen(screen) || ![x, y, screen.width, screen.height].every(Number.isFinite) || screen.width <= 0 || screen.height <= 0)
            return;
        const point = {
            x: x,
            y: y,
            width: screen.width,
            height: screen.height
        };
        positions[screen.name] = point;
        const gates = blocked[screen.name];
        if (!gates)
            return;
        if (!titleContains(point))
            gates.dashboard = false;
        if (x >= edgeWidth)
            gates.left = false;
        if (x < screen.width - edgeWidth)
            gates.osd = false;
    }
    function recordPopupRegion(screen, x, y, width, height) {
        if (validScreen(screen) && [x, y, width, height].every(Number.isFinite) && width > 0 && height > 0)
            popupRegions[screen.name] = {
                x: x,
                y: y,
                width: width,
                height: height
            };
    }
    function popupAtPointer(name) {
        const point = positions[name], box = popupRegions[name];
        return !!point && !!box && point.x >= box.x && point.y >= box.y && point.x < box.x + box.width && point.y < box.y + box.height;
    }
    function dismiss(screen) {
        if (!validScreen(screen))
            return;
        const point = positions[screen.name];
        blocked[screen.name] = {
            dashboard: titleContains(point),
            left: !!point && point.x < edgeWidth,
            osd: !!point && point.x >= point.width - edgeWidth,
            popouts: popupHovered[screen.name] === true || popupAtPointer(screen.name)
        };
    }
    function rearm(name, screen) {
        if (validScreen(screen) && blocked[screen.name] && ["dashboard", "left", "osd", "popouts"].includes(name))
            blocked[screen.name][name] = false;
    }
    function register(name, owner) {
        if (name && owner)
            owners[name] = owner;
    }
    function release(name, owner) {
        if (owners[name] !== owner)
            return;
        for (const map of [positions, blocked, headers, popupHovered, popupRegions, owners])
            delete map[name];
    }
}
