pragma Singleton

import Quickshell
import QtQuick

Singleton {
    property bool hidden: false
    property real reveal: hidden ? 0 : 1
    Behavior on reveal { NumberAnimation { duration: 200; easing.type: Easing.InOutCubic } }
    property var screens: ({})
    property var panels: ({})

    function popout(name,center,screenName) {
        const v=screens[screenName],p=panels[screenName];
        if(!v||!p||v.session)return;
        v.dashboard=false;v.osd=false;
        if(p.popouts.currentName!==name)p.popouts.pinned=false;
        p.popouts.currentName=name;p.popouts.currentCenter=center;p.popouts.hasCurrent=true;
    }
    function getForActive(): PersistentProperties {
        return screens[Hyprland.focusedMonitor?.name] || Object.values(screens)[0] || null;
    }
}
