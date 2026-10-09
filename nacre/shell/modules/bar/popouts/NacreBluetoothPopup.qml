import QtQuick
import qs.widgets
import qs.services

Item {
    id: root
    readonly property var known: NacreBluetooth.devices.filter(device => device && (device.connected || device.paired || device.trusted))
    implicitWidth: 320
    implicitHeight: body.implicitHeight
    function activate(device) {
        const current = known.find(entry => device?.address && entry.address === device.address);
        if (DeviceActions.busy || !NacreBluetooth.powered || !current)
            return false;
        DeviceActions.request([current.connected ? "bluetooth-disconnect" : "bluetooth-connect", current.address]);
        return true;
    }
    Column {
        id: body
        width: root.width
        spacing: 10
        Row {
            width: parent.width
            spacing: 12
            NacreText {
                width: parent.width - 100
                anchors.verticalCenter: parent.verticalCenter
                text: "Bluetooth"
                font.pointSize: 14
            }
            ActionButton {
                objectName: "quickBluetoothPower"
                text: NacreBluetooth.powered ? "Turn off" : "Turn on"
                compact: true
                enabled: !DeviceActions.busy
                onClicked: if (enabled)
                    DeviceActions.request(["bluetooth-power", NacreBluetooth.powered ? "off" : "on"])
            }
        }
        NacreQuickList {
            width: parent.width
            Column {
                width: parent.width
                spacing: 6
                Repeater {
                    model: root.known
                    delegate: Item {
                        required property var modelData
                        width: parent.width - 10
                        height: 38
                        NacreText {
                            width: parent.width - 110
                            height: parent.height
                            text: parent.modelData.alias || parent.modelData.name || "Bluetooth device"
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        ActionButton {
                            objectName: "quickBluetoothConnection"
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: parent.modelData.connected ? "Disconnect" : "Connect"
                            compact: true
                            enabled: !DeviceActions.busy && NacreBluetooth.powered
                            onClicked: root.activate(parent.modelData)
                        }
                    }
                }
            }
        }
        NacreText {
            width: parent.width
            visible: !NacreBluetooth.powered || root.known.length === 0
            text: NacreBluetooth.powered ? "No known devices" : "Bluetooth is off"
            color: NacreTokens.mutedInk
        }
        NacreText {
            width: parent.width
            visible: text !== ""
            text: DeviceActions.message || ""
            maximumLineCount: 3
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            color: NacreTokens.mutedInk
        }
    }
}
