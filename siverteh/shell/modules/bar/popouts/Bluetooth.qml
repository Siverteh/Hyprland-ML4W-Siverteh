import qs.widgets
import qs.services
import QtQuick

Item {
    id: root
    implicitWidth: 340
    width: implicitWidth
    implicitHeight: body.implicitHeight
    readonly property var known: Bluetooth.devices.filter(d => d.paired || d.trusted || d.connected).sort((a, b) => Number(b.connected) - Number(a.connected))
    Column {
        id: body
        width: root.width
        spacing: 12
        StyledText {
            text: "Bluetooth"
            font.pointSize: 14
            color: Colours.palette.m3primary
        }
        ActionButton {
            objectName: "quickBluetoothPower"
            text: Bluetooth.powered ? "Bluetooth on" : "Bluetooth off"
            selected: Bluetooth.powered
            enabled: !DeviceActions.busy
            onClicked: DeviceActions.request(["bluetooth-power", Bluetooth.powered ? "off" : "on"])
        }
        QuickList {
            visible: Bluetooth.powered
            Repeater {
                model: root.known
                StyledRect {
                    id: device
                    required property var modelData
                    width: parent.width
                    height: 48
                    radius: 10
                    color: modelData.connected ? Colours.palette.m3primaryContainer : Colours.palette.m3surfaceContainerHigh
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 115
                        spacing: 3
                        StyledText {
                            width: parent.width
                            text: device.modelData.alias || device.modelData.name
                            elide: Text.ElideRight
                            font.pointSize: 10
                        }
                        StyledText {
                            text: device.modelData.connected ? "Connected" : "Not connected"
                            font.pointSize: 9
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                    ActionButton {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: device.modelData.connected ? "Disconnect" : "Connect"
                        compact: true
                        enabled: !DeviceActions.busy
                        onClicked: DeviceActions.request([device.modelData.connected ? "bluetooth-disconnect" : "bluetooth-connect", device.modelData.address])
                    }
                }
            }
        }
        StyledText {
            width: parent.width
            wrapMode: Text.Wrap
            visible: !Bluetooth.powered || !root.known.length
            text: !Bluetooth.powered ? "Turn on Bluetooth to connect your devices." : "No known devices. Open Bluetooth settings to find and pair one."
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }
        StyledText {
            width: parent.width
            visible: DeviceActions.lastAction.startsWith("bluetooth") && text.length > 0
            text: DeviceActions.message
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
            font.pointSize: 9
            color: Colours.palette.m3onSurfaceVariant
        }
        ActionButton {
            objectName: "quickSettingsLink"
            text: "Bluetooth settings"
            icon: "settings"
            onClicked: Visibilities.openSettings("bluetooth")
        }
    }
}
