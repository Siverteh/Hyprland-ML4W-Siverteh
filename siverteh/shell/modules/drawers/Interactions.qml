import qs.services
import qs.config
import qs.modules.bar.popouts as BarPopouts
import qs.modules.osd as Osd
import Quickshell
import QtQuick

MouseArea {
    id: root

    required property ShellScreen screen
    required property BarPopouts.Wrapper popouts
    required property PersistentProperties visibilities
    required property Panels panels
    required property Item bar

    property bool osdHovered
    property point dragStart

    function withinPanelHeight(panel: Item, x: real, y: real): bool {
        const panelY = panels.y + panel.y;
        return y >= panelY - BorderConfig.rounding && y <= panelY + panel.height + BorderConfig.rounding;
    }

    function inRightPanel(panel: Item, x: real, y: real): bool {
        return x > bar.implicitWidth + panel.x && withinPanelHeight(panel, x, y);
    }

    function inTopPanel(panel: Item, x: real, y: real): bool {
        const panelX = bar.implicitWidth + panel.x;
        return y < panels.y + panel.y + panel.height && x >= panelX - BorderConfig.rounding && x <= panelX + panel.width + BorderConfig.rounding;
    }

    anchors.fill: parent
    hoverEnabled: true

    acceptedButtons: (visibilities.launcher || !!visibilities.edgeMenu || (visibilities.dashboard && visibilities.dashboardPinned)) ? (Qt.LeftButton | Qt.RightButton | Qt.MiddleButton) : Qt.LeftButton
    onPressed: event => {
        if (visibilities.launcher) {
            const p = panels.launcher.mapFromItem(root, event.x, event.y);
            if (p.x < 0 || p.y < 0 || p.x > panels.launcher.width || p.y > panels.launcher.height)
                visibilities.launcher = false;
            event.accepted = true;
            return;
        }
        if (visibilities.edgeMenu !== "" || (visibilities.dashboard && visibilities.dashboardPinned)) {
            const panel = visibilities.edgeMenu === "left" ? panels.leftDrawer : visibilities.edgeMenu === "osd" ? panels.osd : panels.dashboard;
            const p = panel.mapFromItem(root, event.x, event.y);
            if (p.x < 0 || p.y < 0 || p.x > panel.width || p.y > panel.height) {
                visibilities.dashboard = false;
                visibilities.left = false;
                visibilities.osd = false;
            }
            event.accepted = true;
            return;
        }
        dragStart = Qt.point(event.x, event.y);
    }
    Timer {
        id: exitDelay
        interval: 120
        onTriggered: {
            if (!root.containsMouse && !root.popouts.headerHovered && !root.popouts.pinned)
                root.popouts.hasCurrent = false;
            if (!root.containsMouse && !visibilities.leftPinned && visibilities.edgeMenu !== "left")
                visibilities.left = false;
        }
    }
    onContainsMouseChanged: {
        if (!containsMouse) {
            if (visibilities.edgeMenu !== "osd") visibilities.osd = false;
            osdHovered = false;
            if (!visibilities.dashboardPinned && visibilities.edgeMenu !== "dashboard")
                visibilities.dashboard = false;
            exitDelay.restart();
        }
    }

    onPositionChanged: ({
            x,
            y
        }) => {
        if (visibilities.launcher)
            return;
        // The existing border responds immediately, matching the right-side drawer.
        if (DesktopSettings.data.clickEdgeMenus === false && DesktopSettings.data.leftDrawer !== false && !visibilities.session && !visibilities.launcher && x < bar.implicitWidth && withinPanelHeight(panels.leftDrawer, x, y)) {
            visibilities.dashboard = false;
            visibilities.left = true;
        }

        // Show osd on hover
        const showOsd = !visibilities.session && (DesktopSettings.data.clickEdgeMenus === false || visibilities.osd) && inRightPanel(panels.osd, x, y);
        if (visibilities.edgeMenu !== "osd") visibilities.osd = showOsd;
        osdHovered = showOsd;

        // Show/hide session on drag
        if (pressed && withinPanelHeight(panels.session, x, y)) {
            const dragX = x - dragStart.x;
            if (dragX < -SessionConfig.dragThreshold)
                visibilities.session = true;
            else if (dragX > SessionConfig.dragThreshold)
                visibilities.session = false;
        }

        if (visibilities.left && visibilities.edgeMenu !== "left" && !visibilities.leftPinned && !((x < bar.implicitWidth + panels.leftDrawer.width + BorderConfig.rounding) && withinPanelHeight(panels.leftDrawer, x, y)))
            visibilities.left = false;

        // Show dashboard on hover
        if (DesktopSettings.data.clickEdgeMenus === false && !visibilities.dashboardPinned && visibilities.edgeMenu !== "dashboard")
            visibilities.dashboard = inTopPanel(panels.dashboard, x, y);

        // Header popouts extend down from the top edge and remain while entered.
        if (popouts.hasCurrent && !popouts.headerHovered && !popouts.pinned) {
            const px = bar.implicitWidth + popouts.x, py = panels.y + popouts.y;
            if (y > py + popouts.height + BorderConfig.rounding || x < px - BorderConfig.rounding || x > px + popouts.width + BorderConfig.rounding)
                popouts.hasCurrent = false;
        }
    }

    Osd.Interactions {
        screen: root.screen
        visibilities: root.visibilities
        hovered: root.osdHovered
    }
}
