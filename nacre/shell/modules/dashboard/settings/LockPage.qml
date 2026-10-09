import QtQuick
import qs.services
import qs.widgets

NacreSettingsPage {
    NacreSettingsSection {
        title: "Your lock screen"
        description: "Wallpaper colors, a large clock and live information around the password field."

        Row {
            spacing: 8

            ActionButton {
                text: "Preview layout"
                icon: "preview"
                onClicked: AppLaunch.run(["nacre-shell", "lock-preview"])
            }

            ActionButton {
                text: "Lock now"
                icon: "lock"
                onClicked: AppLaunch.run(["loginctl", "lock-session"])
            }
        }

        NacreSettingToggle {
            label: "Media information and playback controls"
            setting: "lockMedia"
        }

        NacreSettingToggle {
            label: "Weather conditions"
            setting: "lockWeather"
        }

        NacreSettingToggle {
            label: "Notification summaries"
            setting: "lockNotifications"
        }

        NacreSettingToggle {
            label: "Show notification titles and message previews"
            setting: "lockNotificationContents"
        }

        NacreText {
            width: parent.width
            wrapMode: Text.Wrap
            text: "With message previews off, the lock screen shows app names and notification counts. Unlocking always requires your normal password."
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }
    }

    NacreSettingsSection {
        title: "Weather"
        description: "Leave the location empty for an approximate city based on your public IP. Cached conditions remain available offline."

        NacreTextField {
            id: city

            width: parent.width
            height: 40
            text: DesktopSettings.data.weatherLocation ?? ""
            placeholderText: "City, for example Oslo"
            leftPadding: 12

            background: NacreSurface {
                radius: 12
                color: Colours.palette.m3surfaceContainerHigh
            }
        }

        Row {
            spacing: 8

            ActionButton {
                text: "Save location"
                onClicked: DesktopSettings.set("weatherLocation", city.text.trim())
            }

            ActionButton {
                text: "Refresh weather"
                onClicked: Weather.reload()
            }
        }

        NacreSettingToggle {
            label: "Use Fahrenheit"
            setting: "weatherFahrenheit"
        }

        NacreText {
            width: parent.width
            wrapMode: Text.Wrap
            text: Weather.description ? (Weather.location ? Weather.location + " · " : "") + Weather.description + " · " + Weather.displayTemperature : Weather.error || "Weather is not available yet"
            font.pointSize: 11
            color: Colours.palette.m3onSurfaceVariant
        }
    }
}
