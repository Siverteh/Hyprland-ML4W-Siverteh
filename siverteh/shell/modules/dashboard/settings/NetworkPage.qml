import qs.widgets
import qs.services
import QtQuick

SettingsPage {
    SettingsSection {
        title: "Connection"
        description: "Wi-Fi networks reported by NetworkManager."
        StyledText {
            text: Network.active ? "Connected to " + Network.active.ssid : "No active Wi-Fi connection"
            color: Colours.palette.m3primary
        }
        Flow {
            width: parent.width
            spacing: 8
            ActionButton {
                text: "Refresh networks"
                icon: "refresh"
                enabled: !DeviceActions.busy
                onClicked: DeviceActions.request(["wifi-scan"])
            }
            ActionButton {
                text: "Wi-Fi on"
                onClicked: DeviceActions.request(["wifi-radio", "on"])
            }
            ActionButton {
                text: "Wi-Fi off"
                onClicked: DeviceActions.request(["wifi-radio", "off"])
            }
        }
        StyledText {
            width: parent.width
            wrapMode: Text.Wrap
            text: DeviceActions.message
            visible: text.length > 0
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }
    }
    SettingsSection {
        title: "Available Wi-Fi"
        description: "Connecting opens NetworkManager's password prompt when credentials are needed."
        Repeater {
            model: Network.networks.filter((n, i, all) => all.findIndex(a => a.ssid === n.ssid) === i).sort((a, b) => b.strength - a.strength)
            Row {
                required property var modelData
                width: parent.width
                spacing: 8
                Column {
                    width: parent.width - 120
                    spacing: 3
                    StyledText {
                        width: parent.width
                        elide: Text.ElideRight
                        text: parent.parent.modelData.ssid
                        font.pointSize: 12
                    }
                    StyledText {
                        text: parent.parent.modelData.strength + "% signal · " + Math.round(parent.parent.modelData.frequency / 1000 * 10) / 10 + " GHz"
                        font.pointSize: 10
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
                ActionButton {
                    text: parent.modelData.active ? "Connected" : "Connect"
                    selected: parent.modelData.active
                    enabled: !parent.modelData.active
                    onClicked: DeviceActions.connectWifi(parent.modelData.ssid)
                }
            }
        }
        StyledText {
            visible: Network.networks.length === 0
            text: "No Wi-Fi networks found"
            color: Colours.palette.m3onSurfaceVariant
        }
    }
    SettingsSection {
        title: "Connection profiles"
        description: "Manage Ethernet, VPN, saved Wi-Fi and advanced connection options."
        ActionButton {
            text: "Edit connection profiles"
            icon: "settings_ethernet"
            onClicked: AppLaunch.run(["nm-connection-editor"])
        }
    }
}
