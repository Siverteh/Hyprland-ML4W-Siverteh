pragma Singleton
import Quickshell

Singleton {
    readonly property var edgeWidth: NacreHoverIntent.edgeWidth
    readonly property var dashboardDepth: NacreHoverIntent.dashboardDepth
    readonly property var positions: NacreHoverIntent.positions
    readonly property var blocked: NacreHoverIntent.blocked
    readonly property var headers: NacreHoverIntent.headers
    readonly property var popupHovered: NacreHoverIntent.popupHovered
    readonly property var popupRegions: NacreHoverIntent.popupRegions
    function fullscreenFor(name) {
        return NacreHoverIntent.fullscreenFor(name);
    }
    function canAuto(screen, buttons) {
        return NacreHoverIntent.canAuto(screen, buttons);
    }
    function canOpen(name, screen, buttons) {
        return NacreHoverIntent.canOpen(name, screen, buttons);
    }
    function observe(screen, x, y) {
        NacreHoverIntent.observe(screen, x, y);
    }
    function recordPopupRegion(screen, x, y, width, height) {
        NacreHoverIntent.recordPopupRegion(screen, x, y, width, height);
    }
    function popupAtPointer(name) {
        return NacreHoverIntent.popupAtPointer(name);
    }
    function dismiss(screen) {
        NacreHoverIntent.dismiss(screen);
    }
    function rearm(name, screen) {
        NacreHoverIntent.rearm(name, screen);
    }
}
