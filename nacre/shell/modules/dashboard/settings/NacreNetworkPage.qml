import QtQuick
import qs.widgets
import qs.services

NacreSettingsPage {
    id: root
    property string page: "network"
    function request(action, value) {
        if (!DeviceActions.busy)
            DeviceActions.request(value === undefined ? [action] : [action, value]);
    }
    function connect(network) {
        if (!DeviceActions.busy && Network.visibleNetworks.includes(network) && !network.active && network.ssid)
            DeviceActions.connectWifi(network.ssid);
    }
    NacreSettingsSection {
        title: "Wi-Fi"
        description: Network.active ? "Connected to " + Network.active.ssid : Network.wifiEnabled ? "Not connected" : "Wi-Fi is off"
        Flow {
            width: parent.width
            spacing: 8
            ActionButton {
                text: Network.wifiEnabled ? "Turn Wi-Fi off" : "Turn Wi-Fi on"
                enabled: !DeviceActions.busy
                onClicked: root.request("wifi-radio", Network.wifiEnabled ? "off" : "on")
            }
            ActionButton {
                text: "Scan networks"
                enabled: !DeviceActions.busy && Network.wifiEnabled
                onClicked: root.request("wifi-scan")
            }
            ActionButton {
                text: "Disconnect"
                visible: !!Network.active
                enabled: !DeviceActions.busy && !!Network.wifiInterface
                onClicked: root.request("wifi-disconnect", Network.wifiInterface)
            }
            ActionButton {
                text: "Connection editor"
                onClicked: DesktopActions.execute("network")
            }
        }
    }
    NacreSettingsSection {
        title: "Available networks"
        description: "Passwords are entered in the connection window when needed."
        Repeater {
            model: Network.visibleNetworks
            delegate: Row {
                required property var modelData
                width: parent.width
                spacing: 12
                NacreText {
                    width: Math.max(0, parent.width - connectButton.width - 64)
                    text: parent.modelData.ssid || "Hidden network"
                    wrapMode: Text.Wrap
                    anchors.verticalCenter: parent.verticalCenter
                }
                NacreText {
                    width: 40
                    text: Math.round(parent.modelData.strength) + "%"
                    font.pointSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                }
                ActionButton {
                    id: connectButton
                    text: parent.modelData.active ? "Connected" : "Connect"
                    selected: parent.modelData.active
                    enabled: !DeviceActions.busy && !parent.modelData.active && !!parent.modelData.ssid
                    onClicked: root.connect(parent.modelData)
                }
            }
        }
        NacreText {
            width: parent.width
            visible: Network.visibleNetworks.length === 0
            text: Network.wifiEnabled ? "No networks found. Scan to try again." : "Turn Wi-Fi on to see nearby networks."
            wrapMode: Text.Wrap
            color: NacreTokens.mutedInk
        }
    }
    NacreText {
        width: parent.width
        text: DeviceActions.message
        wrapMode: Text.Wrap
        color: NacreTokens.mutedInk
    }
}
