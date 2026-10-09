pragma Singleton
pragma ComponentBehavior: Bound

import qs.widgets
import qs.config
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    readonly property list<Notif> list: []
    readonly property list<Notif> retained: list.filter(n => n.retain)
    readonly property list<Notif> popups: list.filter(n => n.popup && !DesktopSettings.data.dnd)

    Connections {
        target: DesktopSettings
        function onDataChanged() {
            if (DesktopSettings.data.dnd)
                for (const n of root.list)
                    n.popup = false;
        }
    }

    FileView {
        id: retentionRules
        path: Quickshell.env("HOME") + "/.local/share/nacre/shell/tools/notification-policy.json"
        blockLoading: true
    }
    readonly property var retentionPolicy: {
        try {
            return JSON.parse(retentionRules.text());
        } catch (e) {
            return {};
        }
    }
    function shouldRetain(app, summary, transient) {
        if (transient)
            return false;
        if (!(retentionPolicy.feedbackApps || []).includes(app.toLowerCase()))
            return true;
        return !(retentionPolicy.feedbackSummaries || []).includes(summary) && !(retentionPolicy.feedbackPatterns || []).some(pattern => new RegExp(pattern).test(summary));
    }

    property bool historyReady: false
    property bool dirty: false
    function persist() {
        dirty = true;
        if (historyReady)
            saveDelay.restart();
    }
    function dismiss(entry) {
        const index = list.indexOf(entry);
        if (index < 0)
            return;
        list.splice(index, 1);
        entry.popup = false;
        if (entry.notification)
            entry.notification.dismiss();
        entry.destroy(600);
        persist();
    }
    function clearHistory() {
        for (const entry of [...list])
            dismiss(entry);
    }
    function hidePopups() {
        for (const entry of list)
            entry.popup = false;
    }
    Timer {
        id: saveDelay
        interval: 100
        onTriggered: {
            if (!writer.running) {
                root.dirty = false;
                writer.running = true;
            }
        }
    }
    Process {
        id: reader
        running: true
        command: ["python3", Quickshell.env("HOME") + "/.local/share/nacre/shell/tools/notification-history.py", "load"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: line => {
                try {
                    for (const row of JSON.parse(line))
                        if (!root.list.some(n => n.key === row.key))
                            root.list.push(notifComp.createObject(root, {
                                snapshot: row,
                                key: row.key,
                                time: new Date(row.time),
                                popup: false
                            }));
                } catch (e) {
                    console.warn("Could not read notification history");
                }
            }
        }
        onExited: code => {
            root.historyReady = code === 0;
            if (root.dirty && root.historyReady)
                root.persist();
        }
    }
    Process {
        id: writer
        stdinEnabled: true
        command: ["python3", Quickshell.env("HOME") + "/.local/share/nacre/shell/tools/notification-history.py", "save"]
        onStarted: {
            write(JSON.stringify(root.retained.map(n => n.record())) + "\n");
        }
        onExited: code => {
            if (code !== 0)
                console.warn("Could not save notification history");
            if (root.dirty)
                root.persist();
        }
    }

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true;

            const existing = root.list.find(n => n.notification === notif);
            if (existing) {
                existing.popup = !DesktopSettings.data.dnd;
                root.persist();
                return;
            }
            root.list.push(notifComp.createObject(root, {
                popup: !DesktopSettings.data.dnd,
                notification: notif
            }));
            root.persist();
        }
    }

    CustomShortcut {
        name: "clearNotifs"
        description: "Clear all notifications"
        onPressed: root.hidePopups()
    }

    IpcHandler {
        target: "notifs"
        function counts(): string {
            return JSON.stringify({
                popups: root.popups.length,
                retained: root.retained.length,
                timers: root.popups.map(n => ({
                            running: n.timer.running,
                            hovered: n.hovered,
                            interval: n.timer.interval
                        }))
            });
        }

        function clear(): void {
            root.hidePopups();
        }
        function dismissKey(key: string): void {
            const n = root.list.find(n => n.key === key);
            if (n)
                root.dismiss(n);
        }
        function clearHistory(): void {
            root.clearHistory();
        }
    }

    component Notif: QtObject {
        id: notif

        readonly property bool retain: root.shouldRetain(appName, summary, notification?.transient ?? snapshot.transient ?? false)
        property bool hovered: false
        property bool popup: false
        property string key: Date.now().toString(36) + "-" + Math.random().toString(36).slice(2)
        property var snapshot: ({})
        property date time: new Date()
        readonly property string timeStr: {
            const diff = Time.date.getTime() - time.getTime();
            const m = Math.floor(diff / 60000);
            const h = Math.floor(m / 60);

            if (h < 1 && m < 1)
                return "now";
            if (h < 1)
                return `${m}m`;
            return `${h}h`;
        }

        property Notification notification: null
        readonly property string summary: notification?.summary ?? snapshot.summary ?? ""
        readonly property string body: notification?.body ?? snapshot.body ?? ""
        readonly property string appIcon: notification?.appIcon ?? snapshot.appIcon ?? ""
        readonly property string appName: notification?.appName ?? snapshot.appName ?? ""
        readonly property string image: notification?.image ?? snapshot.image ?? ""
        readonly property var urgency: notification?.urgency ?? snapshot.urgency ?? NotificationUrgency.Normal
        readonly property list<NotificationAction> actions: notification?.actions ?? []
        function record() {
            return {
                key: key,
                time: time.toISOString(),
                summary: summary,
                body: body,
                appName: appName,
                appIcon: appIcon,
                image: image.startsWith("file:") || image.startsWith("/") ? image : "",
                transient: !retain,
                urgency: urgency
            };
        }
        function freeze() {
            if (!retain) {
                root.dismiss(notif);
                return;
            }
            snapshot = record();
            popup = false;
            notification = null;
            root.persist();
        }
        readonly property Connections updates: Connections {
            target: notif.notification
            function onClosed() {
                notif.freeze();
            }
            function onSummaryChanged() {
                root.persist();
            }
            function onBodyChanged() {
                root.persist();
            }
        }

        readonly property Timer timer: Timer {
            running: notif.popup && !notif.hovered && !Visibilities.hidden && !Object.values(Visibilities.panels).some(p => p.notifications.suppressed)
            interval: (notif.notification?.expireTimeout ?? 0) > 0 ? notif.notification.expireTimeout : NotifsConfig.defaultExpireTimeout
            onTriggered: {
                if (NotifsConfig.expire)
                    if (notif.retain)
                        notif.popup = false;
                    else
                        root.dismiss(notif);
            }
        }
    }

    Component {
        id: notifComp

        Notif {}
    }
}
