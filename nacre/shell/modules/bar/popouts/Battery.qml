pragma ComponentBehavior: Bound

import qs.widgets
import qs.services
import qs.config
import Quickshell.Services.UPower
import QtQuick

Column {
    id: root

    spacing: NacreAppearance.spacing.normal
    width: NacreBar.sizes.batteryWidth

    NacreText {
        text: UPower.displayDevice.isLaptopBattery ? qsTr("Remaining: %1%").arg(Math.round(UPower.displayDevice.percentage * 100)) : qsTr("No battery detected")
    }

    NacreText {
        function formatSeconds(s: int, fallback: string): string {
            const day = Math.floor(s / 86400);
            const hr = Math.floor(s / 3600) % 60;
            const min = Math.floor(s / 60) % 60;

            let comps = [];
            if (day > 0)
                comps.push(`${day} days`);
            if (hr > 0)
                comps.push(`${hr} hours`);
            if (min > 0)
                comps.push(`${min} mins`);

            return comps.join(", ") || fallback;
        }

        text: UPower.displayDevice.isLaptopBattery ? qsTr("Time %1: %2").arg(UPower.onBattery ? "remaining" : "until charged").arg(UPower.onBattery ? formatSeconds(UPower.displayDevice.timeToEmpty, "Calculating...") : formatSeconds(UPower.displayDevice.timeToFull, "Fully charged!")) : qsTr("Power profile: %1").arg(PowerProfile.toString(PowerProfiles.profile))
    }

    Loader {
        anchors.horizontalCenter: parent.horizontalCenter

        active: PowerProfiles.degradationReason !== PerformanceDegradationReason.None
        asynchronous: true

        height: active ? (item?.implicitHeight ?? 0) : 0

        sourceComponent: NacreSurface {
            implicitWidth: child.implicitWidth + NacreAppearance.padding.normal * 2
            implicitHeight: child.implicitHeight + NacreAppearance.padding.smaller * 2

            color: Colours.palette.m3error
            radius: NacreAppearance.rounding.normal

            Column {
                id: child

                anchors.centerIn: parent

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: NacreAppearance.spacing.small

                    NacreIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -font.pointSize / 10

                        text: "warning"
                        color: Colours.palette.m3onError
                    }

                    NacreText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Performance Degraded")
                        color: Colours.palette.m3onError
                        font.family: NacreAppearance.font.family.mono
                        font.weight: 500
                    }

                    NacreIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -font.pointSize / 10

                        text: "warning"
                        color: Colours.palette.m3onError
                    }
                }

                NacreText {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: qsTr("Reason: %1").arg(PerformanceDegradationReason.toString(PowerProfiles.degradationReason))
                    color: Colours.palette.m3onError
                }
            }
        }
    }

    NacreSurface {
        id: profiles

        property string current: {
            const p = PowerProfiles.profile;
            if (p === PowerProfile.PowerSaver)
                return saver.icon;
            if (p === PowerProfile.Performance)
                return perf.icon;
            return balance.icon;
        }

        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: saver.implicitHeight + balance.implicitHeight + perf.implicitHeight + NacreAppearance.padding.normal * 2 + NacreAppearance.spacing.large * 2
        implicitHeight: Math.max(saver.implicitHeight, balance.implicitHeight, perf.implicitHeight) + NacreAppearance.padding.small * 2

        color: Colours.palette.m3surfaceContainer
        radius: NacreAppearance.rounding.full

        NacreSurface {
            id: indicator

            color: Colours.palette.m3primary
            radius: NacreAppearance.rounding.full
            state: profiles.current

            states: [
                State {
                    name: saver.icon

                    Fill {
                        item: saver
                    }
                },
                State {
                    name: balance.icon

                    Fill {
                        item: balance
                    }
                },
                State {
                    name: perf.icon

                    Fill {
                        item: perf
                    }
                }
            ]

            transitions: Transition {
                AnchorAnimation {
                    duration: NacreAppearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: NacreAppearance.anim.curves.emphasized
                }
            }
        }

        Profile {
            id: saver

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: NacreAppearance.padding.small

            profile: PowerProfile.PowerSaver
            icon: "energy_savings_leaf"
        }

        Profile {
            id: balance

            anchors.centerIn: parent

            profile: PowerProfile.Balanced
            icon: "balance"
        }

        Profile {
            id: perf

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: NacreAppearance.padding.small

            profile: PowerProfile.Performance
            icon: "rocket_launch"
        }
    }

    component Fill: AnchorChanges {
        required property Item item

        target: indicator
        anchors.left: item.left
        anchors.right: item.right
        anchors.top: item.top
        anchors.bottom: item.bottom
    }

    component Profile: Item {
        required property string icon
        required property int profile

        implicitWidth: icon.implicitHeight + NacreAppearance.padding.small * 2
        implicitHeight: icon.implicitHeight + NacreAppearance.padding.small * 2

        NacreInteraction {
            radius: NacreAppearance.rounding.full
            color: profiles.current === parent.icon ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface

            function onClicked(): void {
                PowerProfiles.profile = parent.profile;
            }
        }

        NacreIcon {
            id: icon

            anchors.centerIn: parent

            text: parent.icon
            font.pointSize: NacreAppearance.font.size.large
            color: profiles.current === text ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
            fill: profiles.current === text ? 1 : 0

            Behavior on fill {
                NumberAnimation {
                    duration: NacreAppearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: NacreAppearance.anim.curves.standard
                }
            }
        }
    }
}
