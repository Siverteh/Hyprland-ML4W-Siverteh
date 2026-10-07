import qs.widgets
import qs.services
import QtQuick

Item {
    id: root
    implicitWidth: 340
    width: implicitWidth
    implicitHeight: body.implicitHeight
    readonly property var nearby: Network.networks.filter((n, i, all) => all.findIndex(a => a.ssid === n.ssid) === i).sort((a, b) => Number(b.active) - Number(a.active) || b.strength - a.strength)
    Column {
        id: body
        width: root.width
        spacing: 12
        StyledText {
            text: "Wi-Fi"
            font.pointSize: 14
            color: Colours.palette.m3primary
        }
        StyledText {
            width: parent.width
            text: !Network.wifiEnabled ? "Wi-Fi is off" : Network.active ? "Connected to " + Network.active.ssid : "Not connected"
            wrapMode: Text.Wrap
            font.pointSize: 11
        }
        Flow {
            width: parent.width
            spacing: 8
            ActionButton {
                objectName: "quickWifiPower"
                text: Network.wifiEnabled ? "Wi-Fi on" : "Wi-Fi off"
                selected: Network.wifiEnabled
                enabled: !DeviceActions.busy
                onClicked: DeviceActions.request(["wifi-radio", Network.wifiEnabled ? "off" : "on"])
            }
            ActionButton {
                text: "Refresh"
                icon: "refresh"
                enabled: Network.wifiEnabled && !DeviceActions.busy
                onClicked: DeviceActions.request(["wifi-scan"])
            }
            ActionButton {
                text: "Disconnect"
                visible: !!Network.wifiInterface
                enabled: !DeviceActions.busy
                onClicked: DeviceActions.request(["wifi-disconnect", Network.wifiInterface])
            }
        }
        QuickList {
            visible: Network.wifiEnabled
            Repeater {
                model: root.nearby
                StyledRect {
                    id: network
                    required property var modelData
                    width: parent.width
                    height: 48
                    radius: 10
                    color: modelData.active ? Colours.palette.m3primaryContainer : Colours.palette.m3surfaceContainerHigh
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 110
                        spacing: 3
                        StyledText {
                            width: parent.width
                            text: network.modelData.ssid
                            elide: Text.ElideRight
                            font.pointSize: 10
                        }
                        StyledText {
                            text: network.modelData.strength + "% signal"
                            font.pointSize: 9
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                    ActionButton {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: network.modelData.active ? "Connected" : "Connect"
                        compact: true
                        selected: network.modelData.active
                        enabled: !network.modelData.active && !DeviceActions.busy
                        onClicked: DeviceActions.connectWifi(network.modelData.ssid)
                    }
                }
            }
        }
        StyledText {
            visible: Network.wifiEnabled && !root.nearby.length
            text: "No nearby networks found"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: 10
        }
        StyledText {
            width: parent.width
            visible: DeviceActions.lastAction.startsWith("wifi") && text.length > 0
            text: DeviceActions.message
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
            font.pointSize: 9
            color: Colours.palette.m3onSurfaceVariant
        }
        ActionButton {
            objectName: "quickSettingsLink"
            text: "Network settings"
            icon: "settings"
            onClicked: Visibilities.openSettings("network")
        }
    }
}
