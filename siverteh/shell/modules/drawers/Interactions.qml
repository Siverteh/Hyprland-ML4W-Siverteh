import "root:/services"
import "root:/config"
import "root:/modules/bar/popouts" as BarPopouts
import "root:/modules/osd" as Osd
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
        const panelY = BorderConfig.thickness + panel.y;
        return y >= panelY - BorderConfig.rounding && y <= panelY + panel.height + BorderConfig.rounding;
    }

    function inRightPanel(panel: Item, x: real, y: real): bool {
        return x > bar.implicitWidth + panel.x && withinPanelHeight(panel, x, y);
    }

    function inTopPanel(panel: Item, x: real, y: real): bool {
        const panelX = bar.implicitWidth + panel.x;
        return y < BorderConfig.thickness + panel.y + panel.height && x >= panelX - BorderConfig.rounding && x <= panelX + panel.width + BorderConfig.rounding;
    }

    anchors.fill: parent
    hoverEnabled: true

    onPressed: event => dragStart = Qt.point(event.x, event.y)
    onContainsMouseChanged: {
        if (!containsMouse) {
            visibilities.osd = false;
            osdHovered = false;
            visibilities.dashboard = false;
            popouts.hasCurrent = false;
        }
    }

    onPositionChanged: ({x, y}) => {
        // Show osd on hover
        const showOsd = !visibilities.session && inRightPanel(panels.osd, x, y);
        visibilities.osd = showOsd;
        osdHovered = showOsd;

        // Show/hide session on drag
        if (pressed && withinPanelHeight(panels.session, x, y)) {
            const dragX = x - dragStart.x;
            if (dragX < -SessionConfig.dragThreshold)
                visibilities.session = true;
            else if (dragX > SessionConfig.dragThreshold)
                visibilities.session = false;
        }

        // Show dashboard on hover
        visibilities.dashboard = inTopPanel(panels.dashboard, x, y);

        // Header popouts extend down from the top edge and remain while entered.
        if(popouts.hasCurrent){
            const px=bar.implicitWidth+popouts.x,py=BorderConfig.thickness+popouts.y;
            if(y>py+popouts.height+BorderConfig.rounding||x<px-BorderConfig.rounding||x>px+popouts.width+BorderConfig.rounding)popouts.hasCurrent=false;
        }

    }

    Osd.Interactions {
        screen: root.screen
        visibilities: root.visibilities
        hovered: root.osdHovered
    }
}
