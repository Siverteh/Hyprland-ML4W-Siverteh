pragma ComponentBehavior: Bound
import qs.widgets
import qs.services
import qs.config
import qs.modules.bar.components as Native

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Variants {
    model: DisplayRecovery.surfaceScreens
    NacreWindow {
        id: win
        required property ShellScreen modelData
        screen: modelData
        name: "topbar"
        visible: DesktopSettings.data.topEdge !== false
        contentItem.opacity: Visibilities.reveal
        mask: Region {
            width: Visibilities.hidden ? 0 : win.width
            height: win.height
        }
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: NacreFrame.headerHeight
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        color: "transparent"
        readonly property bool clickMenus: DesktopSettings.data.clickEdgeMenus === true
        property string hoverHint: ""
        Rectangle {
            anchors.fill: parent
            color: NacreTokens.body
        }
        readonly property var visibility: Visibilities.screens[screen.name]
        Timer {
            id: dismissPopout
            interval: 120
            onTriggered: {
                const p = Visibilities.panels[win.screen.name];
                if (p) {
                    p.popouts.headerHovered = statusHover.containsMouse || calendarHover.containsMouse;
                    if (!p.popouts.pinned && !p.popouts.headerHovered && !p.parent.containsMouse)
                        p.popouts.hasCurrent = false;
                }
            }
        }
        function hoverMenu(name, item) {
            const cursor = item.mapToItem(win.contentItem, item.mouseX, item.mouseY);
            HoverIntent.observe(win.screen, cursor.x, cursor.y);
            dismissPopout.stop();
            if (win.clickMenus || !HoverIntent.canOpen("popouts", win.screen, item.pressedButtons))
                return;
            const panel = Visibilities.panels[screen.name];
            if (panel)
                panel.popouts.headerHovered = true;
            const p = item.mapToItem(win.contentItem, item.width / 2, 0);
            Visibilities.popout(name, p.x, screen.name);
        }
        RowLayout {
            id: leftGroup
            anchors.left: parent.left
            anchors.leftMargin: NacreAppearance.padding.large
            anchors.verticalCenter: parent.verticalCenter
            spacing: NacreAppearance.spacing.normal
            BrandLogo {
                compact: true
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        win.visibility.launcherMode = "apps";
                        win.visibility.launcherQuery = "";
                        win.visibility.launcherRequest++;
                        win.visibility.launcher = !win.visibility.launcher;
                    }
                }
            }
            NacreSurface {
                radius: NacreAppearance.rounding.full
                color: Colours.palette.m3surfaceContainer
                implicitHeight: 34
                implicitWidth: workspaces.implicitWidth + NacreAppearance.padding.small * 2
                WorkspaceStrip {
                    id: workspaces
                    anchors.centerIn: parent
                }
            }
        }
        NacreText {
            anchors.centerIn: parent
            visible: win.hoverHint !== ""
            text: win.hoverHint
            color: Colours.palette.m3onSurfaceVariant
        }
        Native.ActiveWindow {
            visible: win.hoverHint === ""
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(100, Math.min(650, win.width - 2 * Math.max(leftGroup.width, rightGroup.width) - 50))
            height: 30
            horizontal: true
            monitor: Brightness.getMonitorForScreen(win.screen)
        }
        RowLayout {
            id: rightGroup
            anchors.right: parent.right
            anchors.rightMargin: NacreAppearance.padding.large
            anchors.verticalCenter: parent.verticalCenter
            spacing: NacreAppearance.spacing.normal
            Item {
                implicitWidth: updateRow.implicitWidth
                implicitHeight: 34
                Row {
                    id: updateRow
                    anchors.centerIn: parent
                    spacing: 4
                    NacreIcon {
                        text: "package_2"
                        color: Colours.palette.m3primary
                    }
                    NacreText {
                        text: Updates.message || String(Updates.count)
                        color: Colours.palette.m3primary
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        connectionManager.command = ["nacre-shell", "updates"];
                        AppLaunch.run(connectionManager.command);
                    }
                }
            }
            NacreSurface {
                id: statusHolder
                radius: NacreAppearance.rounding.full
                color: Colours.palette.m3surfaceContainer
                implicitWidth: status.implicitHeight + NacreAppearance.padding.normal * 2
                implicitHeight: 34
                Native.StatusIcons {
                    id: status
                    anchors.centerIn: parent
                    rotation: -90
                    horizontal: true
                }
                MouseArea {
                    id: statusHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    function menuName() {
                        const icons = [status.audioItem, status.network, status.bluetoothItem, status.battery, status.notificationsItem];
                        let best = Infinity, index = 0;
                        for (let i = 0; i < icons.length; i++) {
                            const icon = icons[i], x = icon.mapToItem(statusHover, icon.width / 2, icon.height / 2).x, d = Math.abs(mouseX - x);
                            if (d < best) {
                                best = d;
                                index = i;
                            }
                        }
                        return ["audio", "network", "bluetooth", "battery", "notifications"][index];
                    }
                    function showMenu(clicked = false) {
                        const cursor = statusHover.mapToItem(win.contentItem, statusHover.mouseX, statusHover.mouseY);
                        HoverIntent.observe(win.screen, cursor.x, cursor.y);
                        if (!clicked && !HoverIntent.canOpen("popouts", win.screen, statusHover.pressedButtons))
                            return;
                        if (win.clickMenus && !clicked) {
                            win.hoverHint = ({
                                    audio: "Open Sound settings",
                                    network: "Open Network settings",
                                    bluetooth: "Open Bluetooth settings",
                                    battery: "Open Battery",
                                    notifications: "Open Notifications"
                                })[menuName()];
                            return;
                        }
                        if (win.visibility?.dashboard && win.visibility.dashboardPinned)
                            return;
                        const name = menuName(), p = Visibilities.panels[win.screen.name];
                        dismissPopout.stop();
                        if (p)
                            p.popouts.headerHovered = true;
                        if (p && (!p.popouts.hasCurrent || p.popouts.currentName !== name)) {
                            const index = ["audio", "network", "bluetooth", "battery", "notifications"].indexOf(name);
                            const icon = [status.audioItem, status.network, status.bluetoothItem, status.battery, status.notificationsItem][index];
                            const pt = icon.mapToItem(win.contentItem, icon.width / 2, icon.height / 2);
                            dismissPopout.stop();
                            p.popouts.headerHovered = true;
                            Visibilities.popout(name, pt.x, win.screen.name);
                        }
                    }
                    onEntered: {
                        HoverIntent.popupHovered[win.screen.name] = true;
                        showMenu();
                    }
                    onPositionChanged: if (containsMouse)
                        showMenu()
                    onExited: {
                        HoverIntent.popupHovered[win.screen.name] = false;
                        HoverIntent.rearm("popouts", win.screen);
                        win.hoverHint = "";
                        const p = Visibilities.panels[win.screen.name];
                        if (p)
                            p.popouts.headerHovered = calendarHover.containsMouse;
                        dismissPopout.restart();
                    }
                    onClicked: {
                        const name = menuName(), p = Visibilities.panels[win.screen.name];
                        if (Visibilities.openDeviceSettings(name))
                            return;
                        if (name === "notifications") {
                            if (p.popouts.hasCurrent && p.popouts.pinned && p.popouts.currentName === name)
                                p.popouts.hasCurrent = false;
                            else {
                                showMenu(true);
                                p.popouts.pinned = true;
                            }
                        } else {
                            showMenu(true);
                            if (win.clickMenus)
                                p.popouts.pinned = true;
                        }
                    }
                }
            }
            Item {
                id: calendarItem
                implicitWidth: clockRow.implicitWidth
                implicitHeight: 34
                Row {
                    id: clockRow
                    anchors.centerIn: parent
                    spacing: NacreAppearance.spacing.small
                    NacreIcon {
                        text: "calendar_month"
                        color: Colours.palette.m3tertiary
                    }
                    NacreText {
                        text: Time.format("HH:mm")
                        color: Colours.palette.m3tertiary
                    }
                }
                MouseArea {
                    id: calendarHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        HoverIntent.popupHovered[win.screen.name] = true;
                        if (win.clickMenus)
                            win.hoverHint = "Open Calendar";
                        else
                            win.hoverMenu("calendar", this);
                    }
                    onExited: {
                        HoverIntent.popupHovered[win.screen.name] = false;
                        HoverIntent.rearm("popouts", win.screen);
                        win.hoverHint = "";
                        const p = Visibilities.panels[win.screen.name];
                        if (p)
                            p.popouts.headerHovered = statusHover.containsMouse;
                        dismissPopout.restart();
                    }
                    onClicked: {
                        if (win.clickMenus) {
                            const p = Visibilities.panels[win.screen.name];
                            const pt = mapToItem(win.contentItem, width / 2, 0);
                            Visibilities.popout("calendar", pt.x, win.screen.name);
                            p.popouts.pinned = true;
                        } else
                            win.hoverMenu("calendar", this);
                    }
                }
            }
            Native.Power {}
        }
        MouseArea {
            id: dashboardHover
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(700, parent.width * 0.45)
            height: win.height
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            function updateEdge(buttons, localX, localY) {
                HoverIntent.observe(win.screen, localX + x, localY);
                HoverIntent.headers[win.screen.name] = containsMouse;
                if (!win.clickMenus && localY <= HoverIntent.dashboardDepth && win.visibility && !win.visibility.session && !win.visibility.launcher && HoverIntent.canOpen("dashboard", win.screen, buttons)) {
                    const p = Visibilities.panels[win.screen.name];
                    if (p)
                        p.popouts.hasCurrent = false;
                    win.visibility.dashboard = true;
                }
            }
            onEntered: HoverIntent.headers[win.screen.name] = true
            onPositionChanged: event => updateEdge(event.buttons, event.x, event.y)
            onExited: {
                HoverIntent.headers[win.screen.name] = false;
                HoverIntent.rearm("dashboard", win.screen);
                dashboardExit.restart();
            }
            Timer {
                id: dashboardExit
                interval: 140
                onTriggered: {
                    const p = Visibilities.panels[win.screen.name];
                    if (!win.clickMenus && !dashboardHover.containsMouse && !p?.parent.containsMouse && !win.visibility?.dashboardPinned)
                        win.visibility.dashboard = false;
                }
            }
        }
        EdgeMenuHandle {
            anchors.centerIn: parent
            z: 3
            visible: win.clickMenus && !Visibilities.hidden && win.visibility?.edgeMenu === "" && !win.visibility?.dashboard && !win.visibility?.launcher && !win.visibility?.session
            externalHovered: dashboardHover.containsMouse
            icon: "expand_more"
            onClicked: Visibilities.openEdge("dashboard", win.screen.name)
        }
    }
}
