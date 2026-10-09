pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property string presentation: JSON.stringify(snapshot())
    property bool dirty: true

    function snapshot() {
        const p = NacrePlayers.active;
        return {
            "colors": NacrePresentation.active.colours,
            "wallpaper": NacrePresentation.active.poster ?? Wallpapers.poster,
            "system": {
                "cpu": NacreSystemUsage.cpuPerc,
                "memory": NacreSystemUsage.memPerc,
                "storage": NacreSystemUsage.storagePerc,
                "temperature": Number.isFinite(NacreSystemUsage.cpuTemp) ? NacreSystemUsage.cpuTemp : null
            },
            "greetingHour": NacreTime.hours,
            "preferences": {
                "lockMedia": DesktopSettings.data.lockMedia,
                "lockWeather": DesktopSettings.data.lockWeather,
                "lockNotifications": DesktopSettings.data.lockNotifications,
                "lockNotificationContents": DesktopSettings.data.lockNotificationContents
            },
            "weather": {
                "location": Weather.location,
                "icon": Weather.icon,
                "detail": Weather.detail,
                "range": Weather.range,
                "description": Weather.description,
                "temperature": Weather.displayTemperature,
                "stale": Weather.stale,
                "error": Weather.error
            },
            "media": p ? {
                "title": p.trackTitle,
                "artist": p.trackArtist,
                "album": p.trackAlbum,
                "art": p.trackArtUrl,
                "playing": p.isPlaying,
                "canToggle": p.canTogglePlaying
            } : null,
            "notifications": NacreNotifs.retained.slice(-64).reverse().map(n => {
                return ({
                        "app": n.appName,
                        "time": n.time.toISOString(),
                        "icon": n.appIcon,
                        "summary": DesktopSettings.data.lockNotificationContents ? n.summary : "",
                        "body": DesktopSettings.data.lockNotificationContents ? n.body : ""
                    });
            }),
            "count": NacreNotifs.retained.length,
            "battery": Math.round(UPower.displayDevice.percentage)
        };
    }

    onPresentationChanged: {
        dirty = true;
        settle.restart();
    }
    Component.onCompleted: settle.restart()

    Timer {
        id: settle

        interval: 100
        onTriggered: {
            if (!writer.running) {
                root.dirty = false;
                writer.running = true;
            }
        }
    }

    Process {
        id: writer

        stdinEnabled: true
        command: ["python3", Quickshell.env("HOME") + "/.local/share/nacre/shell/tools/lock-prepare.py"]
        onStarted: write(root.presentation + "\n")
        onExited: {
            if (root.dirty)
                settle.restart();
        }
    }

    IpcHandler {
        function state(): string {
            return root.presentation;
        }

        target: "lockWidgets"
    }
}
