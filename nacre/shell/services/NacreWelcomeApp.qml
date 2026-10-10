pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool created: false
    property bool visible: false
    property var window: null
    property string page: "home"
    property var data: ({
            preferences: {
                showAtLogin: true
            },
            available: {}
        })
    property string error: ""
    property var queue: []
    property int focusAttempts: 0
    readonly property bool busy: worker.running
    readonly property var client: (NacreHyprland.clients || []).find(c => c.pid === Quickshell.processId && c.title === "Nacre Welcome" && c.wmClass === "org.quickshell") || null
    readonly property bool active: visible && !!window && !window.minimized && (client?.workspace?.id ?? 1) > 0
    function request(args) {
        queue = [...queue, args];
        next();
    }
    function next() {
        if (!worker.running && queue.length) {
            const args = queue[0];
            queue = queue.slice(1);
            worker.command = ["python3", Quickshell.env("HOME") + "/.local/share/nacre/shell/tools/welcome.py", ...args];
            worker.running = true;
        }
    }
    function refresh() {
        if (created && !busy && queue.length === 0)
            request(["state"]);
    }
    function setStartup(value) {
        error = "";
        request(["set-startup", JSON.stringify(value)]);
    }
    function open(section = "home") {
        page = ["home", "shortcuts", "apps", "help"].includes(section) ? section : "home";
        NacrePanelState.clearPopouts();
        const view = NacrePanelState.getForActive();
        if (view)
            NacrePanelState.closeTransient(view);
        created = true;
        visible = true;
        refresh();
        focusAttempts = 0;
        if (window)
            window.activate();
        focusTimer.restart();
    }
    function close() {
        visible = false;
        focusTimer.stop();
    }
    function route(name) {
        if (name === "colors") {
            close();
            NacreColorsApp.open("");
        } else if (name === "wallpaper" || name === "launcher") {
            close();
            NacrePanelState.openMode(name === "wallpaper" ? "wallpaper" : "apps", "", false);
        } else if (name.startsWith("settings:")) {
            const page = name.slice(9);
            if (["appearance", "desktop", "displays", "time", "network", "sound", "ai", "maintenance"].includes(page)) {
                close();
                NacreSettingsApp.open(page);
            }
        } else if (name === "ai" && data.available?.ai) {
            close();
            Quickshell.execDetached(["uwsm", "app", "--", "nacre-ai"]);
        } else if (name === "brain" && data.available?.brain) {
            close();
            Quickshell.execDetached(["uwsm", "app", "--", "nacre-brain", "open"]);
        }
    }
    function link(name) {
        const urls = {
            project: "https://github.com/nacre-desktop/nacre",
            hyprland: "https://wiki.hypr.land/",
            quickshell: "https://quickshell.org/docs/",
            cachyos: "https://wiki.cachyos.org/"
        };
        if (urls[name])
            Quickshell.execDetached(["uwsm", "app", "--", "xdg-open", urls[name]]);
    }
    Timer {
        id: focusTimer
        interval: 80
        repeat: true
        onTriggered: {
            const client = root.client;
            if (!root.visible || ++root.focusAttempts > 12) {
                stop();
                return;
            }
            if (client && /^0x[0-9a-f]+$/i.test(client.address)) {
                if ((client.workspace?.id ?? 1) < 0)
                    NacreHyprland.dispatch('hl.dsp.window.move({window="address:' + client.address + '",workspace="' + Math.max(1, NacreHyprland.activeWsId) + '",follow=false})');
                NacreHyprland.dispatch('hl.dsp.focus({window="address:' + client.address + '"})');
                stop();
            }
        }
    }
    Process {
        id: worker
        stdout: SplitParser {
            splitMarker: ""
            onRead: line => {
                try {
                    const value = JSON.parse(line);
                    if (value.error)
                        root.error = value.error;
                    else {
                        root.data = value;
                        root.error = "";
                    }
                } catch (e) {
                    root.error = "Could not read Welcome preferences. Reopen Welcome to try again.";
                }
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0 && !root.error)
                root.error = "Welcome could not save its preference. Try reopening the app.";
            root.next();
        }
    }
    IpcHandler {
        target: "welcomeApp"
        function open(page: string): void {
            root.open(page);
        }
        function close(): void {
            root.close();
        }
        function refresh(): void {
            root.refresh();
        }
        function setStartup(value: bool): void {
            root.setStartup(value);
        }
        function route(name: string): void {
            root.route(name);
        }
        function state(): string {
            return JSON.stringify({
                created: root.created,
                visible: root.visible,
                active: root.active,
                page: root.page,
                busy: root.busy,
                error: root.error,
                data: root.data,
                width: root.window?.width || 0,
                height: root.window?.height || 0
            });
        }
    }
}
