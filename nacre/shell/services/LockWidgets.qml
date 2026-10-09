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
        const p = Players.active;
        return {
            "colors": ThemePresentation.active.colours,
            "wallpaper": ThemePresentation.active.poster ?? Wallpapers.poster,
            "system": {
                "cpu": SystemUsage.cpuPerc,
                "memory": SystemUsage.memPerc,
                "storage": SystemUsage.storagePerc,
                "temperature": Number.isFinite(SystemUsage.cpuTemp) ? SystemUsage.cpuTemp : null
            },
            "greetingHour": Time.hours,
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
            "notifications": Notifs.retained.slice(-64).reverse().map(n => {
                return ({
                        "app": n.appName,
                        "time": n.time.toISOString(),
                        "icon": n.appIcon,
                        "summary": DesktopSettings.data.lockNotificationContents ? n.summary : "",
                        "body": DesktopSettings.data.lockNotificationContents ? n.body : ""
                    });
            }),
            "count": Notifs.retained.length,
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
