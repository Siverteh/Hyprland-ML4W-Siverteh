import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Scope {
    Variants {
        model: DisplayRecovery.surfaceScreens
        NacreScreen {
            required property ShellScreen modelData
            screen: modelData
        }
    }
    IpcHandler {
        target: "leftEdge"
        function state(): string {
            const name = NacreHyprland.focusedMonitor?.name ?? Object.keys(Visibilities.panels)[0];
            const input = Visibilities.panels[name]?.input;
            return JSON.stringify({
                registered: !!input,
                visible: input?.leftEdgeAvailable ?? false,
                width: NacreHoverIntent.edgeWidth,
                height: input?.leftEdgeRect.height ?? 0
            });
        }
    }
    IpcHandler {
        target: "frame"
        function state(): string {
            return JSON.stringify(Object.entries(Visibilities.panels).map(entry => Object.assign({
                    screen: entry[0]
                }, entry[1].input.describe())));
        }
    }
}
