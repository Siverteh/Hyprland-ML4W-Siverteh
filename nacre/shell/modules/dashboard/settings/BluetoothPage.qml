import QtQuick
import qs.services
import qs.widgets

NacreSettingsPage {
    NacreSettingsSection {
        title: "Bluetooth adapter"

        Row {
            spacing: 8

            ActionButton {
                text: Bluetooth.powered ? "Bluetooth on" : "Bluetooth off"
                selected: Bluetooth.powered
                onClicked: DeviceActions.request(["bluetooth-power", Bluetooth.powered ? "off" : "on"])
            }

            ActionButton {
                text: "Find and pair devices"
                icon: "bluetooth_searching"
                onClicked: AppLaunch.run(["blueman-manager"])
            }
        }

        NacreText {
            width: parent.width
            wrapMode: Text.Wrap
            text: DeviceActions.message
            visible: text.length > 0
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }
    }

    NacreSettingsSection {
        title: "Your devices"
        description: "Connection and trust controls for known devices. Pairing confirmations use the Bluetooth manager."

        Repeater {
            model: Bluetooth.devices

            Column {
                required property var modelData

                width: parent.width
                spacing: 7

                NacreText {
                    text: parent.modelData.alias || parent.modelData.name
                    font.pointSize: 12
                }

                NacreText {
                    text: [parent.modelData.connected ? "Connected" : "Disconnected", parent.modelData.paired ? "Paired" : "Not paired", parent.modelData.trusted ? "Trusted" : "Not trusted"].join(" · ")
                    font.pointSize: 10
                    color: Colours.palette.m3onSurfaceVariant
                }

                Row {
                    spacing: 8

                    ActionButton {
                        text: parent.parent.modelData.connected ? "Disconnect" : "Connect"
                        enabled: !DeviceActions.busy
                        onClicked: DeviceActions.request([parent.parent.modelData.connected ? "bluetooth-disconnect" : "bluetooth-connect", parent.parent.modelData.address])
                    }

                    ActionButton {
                        text: parent.parent.modelData.trusted ? "Remove trust" : "Trust"
                        enabled: !DeviceActions.busy
                        onClicked: DeviceActions.request([parent.parent.modelData.trusted ? "bluetooth-untrust" : "bluetooth-trust", parent.parent.modelData.address])
                    }
                }
            }
        }

        NacreText {
            visible: Bluetooth.devices.length === 0
            text: "No known Bluetooth devices"
            color: Colours.palette.m3onSurfaceVariant
        }
    }
}
