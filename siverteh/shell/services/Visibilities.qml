pragma Singleton

import Quickshell
import QtQuick

Singleton {
    property string settingsPage: "appearance"
    property bool hidden: false
    property real reveal: hidden ? 0 : 1
    Behavior on reveal {
        NumberAnimation {
            duration: DesktopSettings.data.animations === false ? 0 : 200
            easing.type: Easing.InOutCubic
        }
    }
    property var screens: ({})
    property var panels: ({})

    function openEdge(name, screenName) {
        const v = screenName ? screens[screenName] : getForActive();
        if (!v || !["dashboard", "left", "osd"].includes(name)) return;
        for (const p of Object.values(panels)) { p.popouts.hasCurrent = false; p.popouts.pinned = false; }
        v.launcher = false;
        v.session = false;
        v.dashboard = false;
        v.left = false;
        v.leftPinned = false;
        v.osd = false;
        v.previewOnly = false;
        v.edgeMenu = name;
        v[name] = true;
    }
    function popout(name, center, screenName) {
        const v = screens[screenName], p = panels[screenName];
        if (!v || !p || v.session)
            return;
        v.dashboard = false;
        v.osd = false;
        if (p.popouts.currentName !== name)
            p.popouts.pinned = false;
        p.popouts.currentName = name;
        p.popouts.currentCenter = center;
        p.popouts.hasCurrent = true;
    }
    function openMode(mode, query, preview) {
        const v = getForActive();
        if (!v)
            return;
        if (mode === "overview" && DesktopSettings.data.nativeOverview === false) {
            AppLaunch.run(["rofi", "-show", "window"]);
            return;
        }
        if (mode === "clipboard" && DesktopSettings.data.nativeClipboard === false) {
            AppLaunch.run(["siverteh-os-shell", "clipboard"]);
            return;
        }
        if (mode === "palette" && DesktopSettings.data.nativePalette === false) {
            mode = "legacy";
            query = ">";
        }
        v.previewOnly = preview === true;
        const same = v.launcher && v.launcherMode === mode;
        hidden = false;
        v.session = false;
        v.osd = false;
        v.dashboard = false;
        v.left = false;
        v.leftPinned = false;
        for (const p of Object.values(panels))
            p.popouts.hasCurrent = false;
        v.launcherMode = mode;
        v.launcherQuery = query || "";
        v.launcherRequest++;
        v.launcher = !same;
    }
    function openDeviceSettings(icon) {
        const pages = {
            audio: "sound",
            network: "network",
            bluetooth: "bluetooth"
        };
        const page = pages[icon];
        if (!page)
            return false;
        openSettings(page);
        return true;
    }
    function openSettings(page) {
        if (page && ["appearance", "desktop", "displays", "sound", "network", "bluetooth", "notifications", "workflows", "lock", "time", "ai", "maintenance"].includes(page))
            settingsPage = page;
        for (const panel of Object.values(panels)) {
            panel.popouts.hasCurrent = false;
            panel.popouts.pinned = false;
        }
        const v = getForActive();
        if (v) {
            v.previewOnly = false;
            hidden = false;
            v.launcher = false;
            v.session = false;
            v.left = false;
            v.leftPinned = false;
            v.dashboardTab = 4;
            v.dashboard = true;
            v.dashboardPinned = true;
        }
    }
    function toggleLeft() {
        const v = getForActive();
        if (!v)
            return;
        v.previewOnly = false;
        hidden = false;
        v.launcher = false;
        v.session = false;
        v.dashboard = false;
        v.left = !v.left;
        if (!v.left)
            v.leftPinned = false;
    }
    function getForActive(): PersistentProperties {
        return screens[Hyprland.focusedMonitor?.name] || Object.values(screens)[0] || null;
    }
}
