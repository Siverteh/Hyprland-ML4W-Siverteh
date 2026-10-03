pragma Singleton

import Quickshell

Singleton {
    property var screens: ({})
    property var panels: ({})

    function getForActive(): PersistentProperties {
        return screens[Hyprland.focusedMonitor?.name] || Object.values(screens)[0] || null;
    }
}
