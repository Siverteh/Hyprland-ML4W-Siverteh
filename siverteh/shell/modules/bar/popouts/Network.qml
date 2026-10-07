import qs.widgets
import qs.services
import QtQuick

Item {
    id: root
    implicitWidth: 340
    width: implicitWidth
    implicitHeight: body.implicitHeight
    readonly property var nearby: Network.visibleNetworks
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
                            text: (network.modelData.active ? "Connected · " : "") + network.modelData.strength + "% signal"
                            font.pointSize: 9
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                    ActionButton {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        objectName: network.modelData.active ? "connectedWifiAction" : "availableWifiAction"
                        text: network.modelData.active ? "Disconnect" : "Connect"
                        compact: true
                        selected: network.modelData.active
                        enabled: !DeviceActions.busy && (!network.modelData.active || !!Network.wifiInterface)
                        onClicked: {
                            if (network.modelData.active)
                                DeviceActions.request(["wifi-disconnect", Network.wifiInterface]);
                            else
                                DeviceActions.connectWifi(network.modelData.ssid);
                        }
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
    }
}
