import QtQuick
import qs.services
import qs.widgets

SettingsPage {
    Component.onCompleted: TimezoneSettings.refresh()

    SettingsSection {
        title: "Local time"
        description: "The system clock stays synchronized in UTC. Your timezone sets the local time shown by apps."

        NacreText {
            text: TimezoneSettings.status.localTime ?? "Checking local time…"
            font.pointSize: 19
            color: Colours.palette.m3primary
        }

        NacreText {
            text: TimezoneSettings.status.timezone ?? ""
            font.pointSize: 12
        }

        Flow {
            width: parent.width
            spacing: 8

            ActionButton {
                text: "Refresh status"
                icon: "refresh"
                onClicked: TimezoneSettings.refresh()
            }

            ActionButton {
                text: "Check device location"
                icon: "my_location"
                enabled: !TimezoneSettings.busy && TimezoneSettings.status.deviceLocation === true && TimezoneSettings.status.automatic === true
                onClicked: TimezoneSettings.change("update", "force")
            }

            ActionButton {
                text: !TimezoneSettings.status.deviceLocation ? "Upgrade automatic timezone" : TimezoneSettings.status.automatic ? "Turn off automatic timezone" : "Enable automatic timezone"
                selected: TimezoneSettings.status.automatic ?? false
                enabled: !TimezoneSettings.busy
                onClicked: TimezoneSettings.change(TimezoneSettings.status.deviceLocation ? "automatic" : "install", TimezoneSettings.status.deviceLocation ? (TimezoneSettings.status.automatic ? "off" : "on") : (TimezoneSettings.status.timezone ?? ""))
            }
        }

        NacreText {
            width: parent.width
            wrapMode: Text.Wrap
            text: "Automatic mode checks device location through GeoClue on connection changes and every 15 minutes. GPS or nearby Wi-Fi can locate you even on mobile data or a VPN. Imprecise or unavailable fixes keep the last confirmed timezone; public IP location never changes the clock."
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }

        NacreText {
            width: parent.width
            wrapMode: Text.Wrap
            text: "Source: " + (TimezoneSettings.status.source ?? "Not checked") + (TimezoneSettings.status.city ? " · " + TimezoneSettings.status.city : "") + (TimezoneSettings.status.accuracyMeters !== undefined ? " · accuracy " + TimezoneSettings.status.accuracyMeters + " m" : "")
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }

        NacreText {
            width: parent.width
            wrapMode: Text.Wrap
            text: TimezoneSettings.status.error || TimezoneSettings.message
            visible: text.length > 0
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }
    }

    SettingsSection {
        title: "Confirm your local timezone"
        description: "Confirm where you are if device location is unavailable. America/Chicago covers Houston and Dallas; Europe/Oslo covers Norway. Automatic mode remains available."

        NacreTextField {
            id: zone

            width: parent.width
            height: 40
            text: TimezoneSettings.status.timezone ?? ""
            placeholderText: "Area/City"
            leftPadding: 12

            background: NacreSurface {
                radius: 12
                color: Colours.palette.m3surfaceContainerHigh
            }
        }

        ActionButton {
            text: "Confirm current timezone"
            enabled: !TimezoneSettings.busy && TimezoneSettings.status.deviceLocation === true
            onClicked: TimezoneSettings.change("confirm", zone.text.trim())
        }

        ActionButton {
            text: "Use manually (turn off automatic)"
            enabled: !TimezoneSettings.busy && TimezoneSettings.status.installed
            onClicked: TimezoneSettings.change("manual", zone.text.trim())
        }
    }
}
