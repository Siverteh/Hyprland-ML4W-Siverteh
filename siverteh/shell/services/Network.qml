pragma Singleton

import "../utils/scripts/wifi-networks.js" as Wifi
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<AccessPoint> networks: []
    readonly property var visibleNetworks: Wifi.group(networks)
    readonly property AccessPoint active: networks.find(n => n.active) ?? null

    property bool wifiEnabled: true
    property string wifiInterface: ""
    reloadableId: "network"

    function refresh() {
        if (!getNetworks.running)
            getNetworks.running = true;
        if (!getStatus.running)
            getStatus.running = true;
    }

    Process {
        running: true
        command: ["nmcli", "m"]
        stdout: SplitParser {
            onRead: {
                root.refresh();
            }
        }
    }

    Process {
        id: getStatus
        running: true
        command: ["python3", Quickshell.env("HOME") + "/.local/share/siverteh-ai/siverteh-shell/tools/device-actions.py", "network-status"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const status = JSON.parse(data);
                    if (!status.error) {
                        root.wifiEnabled = status.enabled;
                        root.wifiInterface = status.interface;
                    }
                } catch (e) {}
            }
        }
    }
    Process {
        id: getNetworks
        running: true
        command: ["sh", "-c", `nmcli -g ACTIVE,SIGNAL,FREQ,SSID,BSSID d w | jq -ncR '[(inputs | split("(?<!\\\\\\\\):"; "g")) | select(.[3] | length > 0)]'`]
        stdout: SplitParser {
            onRead: data => {
                const networks = JSON.parse(data).map(n => [n[0] === "yes", parseInt(n[1]), parseInt(n[2]), n[3], n[4].replace(/\\/g, "")]);
                const rNetworks = root.networks;

                const destroyed = rNetworks.filter(rn => !networks.find(n => n[2] === rn.frequency && n[3] === rn.ssid && n[4] === rn.bssid));
                for (const network of destroyed)
                    rNetworks.splice(rNetworks.indexOf(network), 1).forEach(n => n.destroy());

                for (const network of networks) {
                    const match = rNetworks.find(n => n.frequency === network[2] && n.ssid === network[3] && n.bssid === network[4]);
                    if (match) {
                        match.active = network[0];
                        match.strength = network[1];
                        match.frequency = network[2];
                        match.ssid = network[3];
                        match.bssid = network[4];
                    } else {
                        rNetworks.push(apComp.createObject(root, {
                            active: network[0],
                            strength: network[1],
                            frequency: network[2],
                            ssid: network[3],
                            bssid: network[4]
                        }));
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "networkStatus"
        function state(): string {
            return JSON.stringify({
                enabled: root.wifiEnabled,
                interface: root.wifiInterface,
                connectedSsid: root.active?.ssid ?? "",
                connectedRow: root.visibleNetworks.find(n => n.ssid === root.active?.ssid)?.active ?? false,
                count: root.visibleNetworks.length
            });
        }
    }

    component AccessPoint: QtObject {
        required property string ssid
        required property string bssid
        required property int strength
        required property int frequency
        required property bool active
    }

    Component {
        id: apComp

        AccessPoint {}
    }
}
