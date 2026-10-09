import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.services
import qs.utils
import qs.widgets

Item {
    id: root

    property bool horizontal: false
    property color colour: Colours.palette.m3secondary
    readonly property Item audioItem: speaker
    readonly property Item notificationsItem: bell
    readonly property Item network: network
    readonly property Item bluetoothItem: bluetooth
    readonly property Item battery: battery

    clip: true
    implicitWidth: Math.max(speaker.implicitWidth, network.implicitWidth, bluetooth.implicitWidth, battery.implicitWidth, bell.implicitWidth)
    implicitHeight: speaker.implicitHeight + network.implicitHeight + bluetooth.implicitHeight + battery.implicitHeight + bell.implicitHeight + NacreAppearance.spacing.small * 4

    NacreIcon {
        id: speaker

        rotation: root.horizontal ? 90 : 0
        text: NacreAudio.muted ? "volume_off" : "volume_up"
        color: root.colour
        anchors.horizontalCenter: parent.horizontalCenter
    }

    NacreIcon {
        id: network

        rotation: root.horizontal ? 90 : 0
        animate: true
        text: NacreNetwork.active ? NacreIcons.getNetworkIcon(NacreNetwork.active.strength ?? 0) : "wifi_off"
        color: root.colour
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: speaker.bottom
        anchors.topMargin: NacreAppearance.spacing.small
    }

    NacreIcon {
        id: bluetooth

        rotation: root.horizontal ? 90 : 0
        anchors.horizontalCenter: network.horizontalCenter
        anchors.top: network.bottom
        anchors.topMargin: NacreAppearance.spacing.small
        animate: true
        text: NacreBluetooth.powered ? "bluetooth" : "bluetooth_disabled"
        color: root.colour
    }

    NacreIcon {
        id: battery

        rotation: root.horizontal ? 90 : 0
        anchors.horizontalCenter: bluetooth.horizontalCenter
        anchors.top: bluetooth.bottom
        anchors.topMargin: NacreAppearance.spacing.small
        animate: true
        text: {
            if (!UPower.displayDevice.isLaptopBattery) {
                if (PowerProfiles.profile === PowerProfile.PowerSaver)
                    return "energy_savings_leaf";

                if (PowerProfiles.profile === PowerProfile.Performance)
                    return "rocket_launch";

                return "balance";
            }
            const perc = UPower.displayDevice.percentage;
            const charging = !UPower.onBattery;
            if (perc === 1)
                return charging ? "battery_charging_full" : "battery_full";

            let level = Math.floor(perc * 7);
            if (charging && (level === 4 || level === 1))
                level--;

            return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
        }
        color: !UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? root.colour : Colours.palette.m3error
        fill: 1
    }

    Item {
        id: bell

        anchors.horizontalCenter: battery.horizontalCenter
        anchors.top: battery.bottom
        anchors.topMargin: NacreAppearance.spacing.small
        implicitWidth: root.horizontal ? bellRow.implicitHeight : bellRow.implicitWidth
        implicitHeight: root.horizontal ? bellRow.implicitWidth : bellRow.implicitHeight

        Row {
            id: bellRow

            anchors.centerIn: parent
            rotation: root.horizontal ? 90 : 0
            spacing: 2

            NacreIcon {
                text: "notifications"
                color: root.colour
                fill: Notifs.retained.length ? 1 : 0
            }

            NacreText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 4
                visible: Notifs.retained.length > 0
                text: Notifs.retained.length
                font.pointSize: 10
                color: root.colour
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: NacreAppearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: NacreAppearance.anim.curves.emphasized
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: NacreAppearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: NacreAppearance.anim.curves.emphasized
        }
    }
}
