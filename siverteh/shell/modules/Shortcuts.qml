import qs.widgets
import qs.services
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool launcherInterrupted

    CustomShortcut {
        name: "dismissHoverEdges"
        description: "Dismiss passive hover menus without taking application focus"
        onPressed: {
            for (const screen of Quickshell.screens) {
                const v = Visibilities.screens[screen.name], p = Visibilities.panels[screen.name];
                if (!v || v.launcher || v.session || v.edgeMenu !== "") continue;
                HoverIntent.dismiss(screen);
                if (!v.dashboardPinned) v.dashboard = false;
                if (!v.leftPinned) v.left = false;
                v.osd = false;
                if (p && !p.popouts.pinned) p.popouts.hasCurrent = false;
            }
        }
    }
    CustomShortcut {
        name: "session"
        description: "Toggle session menu"
        onPressed: {
            const visibilities = Visibilities.getForActive();
            visibilities.session = !visibilities.session;
        }
    }

    CustomShortcut {
        name: "launcher"
        description: "Toggle launcher"
        onPressed: root.launcherInterrupted = false
        onReleased: {
            if (!root.launcherInterrupted) {
                const visibilities = Visibilities.getForActive();
                visibilities.launcher = !visibilities.launcher;
            }
            root.launcherInterrupted = false;
        }
    }

    CustomShortcut {
        name: "launcherInterrupt"
        description: "Interrupt launcher keybind"
        onPressed: root.launcherInterrupted = true
    }

    IpcHandler {
        target: "drawers"

        function toggle(drawer: string): void {
            if (list().split("\n").includes(drawer)) {
                const visibilities = Visibilities.getForActive();
                visibilities.previewOnly = false;
                visibilities[drawer] = !visibilities[drawer];
            } else {
                console.warn(`[IPC] Drawer "${drawer}" does not exist`);
            }
        }

        function list(): string {
            const visibilities = Visibilities.getForActive();
            return Object.keys(visibilities).filter(k => typeof visibilities[k] === "boolean").join("\n");
        }
    }
}
