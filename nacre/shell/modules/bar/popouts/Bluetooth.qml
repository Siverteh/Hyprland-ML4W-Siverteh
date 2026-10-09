import QtQuick
import qs.services
import qs.widgets

Item {
    id: root

    readonly property var known: NacreBluetooth.devices.filter(d => {
        return d.paired || d.trusted || d.connected;
    }).sort((a, b) => {
        return Number(b.connected) - Number(a.connected);
    })

    implicitWidth: 340
    width: implicitWidth
    implicitHeight: body.implicitHeight

    Column {
        id: body

        width: root.width
        spacing: 12

        NacreText {
            text: "Bluetooth"
            font.pointSize: 14
            color: NacreColours.palette.m3primary
        }

        ActionButton {
            objectName: "quickBluetoothPower"
            text: NacreBluetooth.powered ? "Bluetooth on" : "Bluetooth off"
            selected: NacreBluetooth.powered
            enabled: !DeviceActions.busy
            onClicked: DeviceActions.request(["bluetooth-power", NacreBluetooth.powered ? "off" : "on"])
        }

        QuickList {
            visible: NacreBluetooth.powered

            Repeater {
                model: root.known

                NacreSurface {
                    id: device

                    required property var modelData

                    width: parent.width
                    height: 48
                    radius: 10
                    color: modelData.connected ? NacreColours.palette.m3primaryContainer : NacreColours.palette.m3surfaceContainerHigh

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 115
                        spacing: 3

                        NacreText {
                            width: parent.width
                            text: device.modelData.alias || device.modelData.name
                            elide: Text.ElideRight
                            font.pointSize: 10
                        }

                        NacreText {
                            text: device.modelData.connected ? "Connected" : "Not connected"
                            font.pointSize: 9
                            color: NacreColours.palette.m3onSurfaceVariant
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

        NacreText {
            width: parent.width
            wrapMode: Text.Wrap
            visible: !NacreBluetooth.powered || !root.known.length
            text: !NacreBluetooth.powered ? "Turn on Bluetooth to connect your devices." : "No known devices. Open Bluetooth settings to find and pair one."
            font.pointSize: 10
            color: NacreColours.palette.m3onSurfaceVariant
        }

        NacreText {
            width: parent.width
            visible: DeviceActions.lastAction.startsWith("bluetooth") && text.length > 0
            text: DeviceActions.message
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
            font.pointSize: 9
            color: NacreColours.palette.m3onSurfaceVariant
        }
    }
}
