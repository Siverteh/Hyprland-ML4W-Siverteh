import QtQuick
import qs.services

MouseArea {
    id: root
    required property var screen
    required property var visibility
    property bool clickMenus: false
    width: Math.min(700, parent.width * .45)
    height: parent.height
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    function observe(buttons, x, y) {
        NacreHoverIntent.observe(screen, x + root.x, y);
        NacreHoverIntent.headers[screen.name] = containsMouse;
        if (clickMenus || y > NacreHoverIntent.dashboardDepth || !visibility || visibility.session || visibility.launcher || visibility.dashboardPinned || !NacreHoverIntent.canOpen("dashboard", screen, buttons))
            return;
        const panel = NacrePanelState.panels[screen.name];
        if (panel)
            panel.popouts.hasCurrent = false;
        visibility.dashboard = true;
    }
    onEntered: NacreHoverIntent.headers[screen.name] = true
    onPositionChanged: event => observe(event.buttons, event.x, event.y)
    onExited: {
        NacreHoverIntent.headers[screen.name] = false;
        NacreHoverIntent.rearm("dashboard", screen);
        expiry.restart();
    }
    Timer {
        id: expiry
        interval: 120
        onTriggered: {
            const panel = NacrePanelState.panels[root.screen.name];
            if (!root.clickMenus && !root.containsMouse && !panel?.dashboardHovered && !root.visibility?.dashboardPinned && root.visibility?.edgeMenu !== "dashboard")
                root.visibility.dashboard = false;
        }
    }
}
