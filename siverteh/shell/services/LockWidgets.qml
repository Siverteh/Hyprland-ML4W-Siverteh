pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
    IpcHandler {
        target: "lockWidgets"
        function state(): string {
            const p = Players.active;
            return JSON.stringify({
                preferences: {
                    lockMedia: DesktopSettings.data.lockMedia,
                    lockWeather: DesktopSettings.data.lockWeather,
                    lockNotifications: DesktopSettings.data.lockNotifications
                },
                weather: {
                    location: Weather.location,
                    description: Weather.description,
                    temperature: Weather.displayTemperature,
                    stale: Weather.stale,
                    error: Weather.error
                },
                media: p ? {
                    title: p.trackTitle,
                    artist: p.trackArtist,
                    album: p.trackAlbum,
                    art: p.trackArtUrl,
                    playing: p.isPlaying,
                    canToggle: p.canTogglePlaying
                } : null,
                notifications: Notifs.retained.slice(-8).reverse().map(n => ({
                            app: n.appName,
                            summary: DesktopSettings.data.lockNotificationContents ? n.summary : "",
                            body: DesktopSettings.data.lockNotificationContents ? n.body : ""
                        })),
                count: Notifs.retained.length
            });
        }
    }
}
