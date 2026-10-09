import QtQuick
import QtTest
import "fixtures"
import "wifi-networks.js" as Wifi

TestCase {
    id: test

    property var groupedAPs: Wifi.group([firstAP, secondAP])

    function init() {
        Visibilities.screens = ({
                "test": {
                    "dashboard": false
                }
            });
        Visibilities.panels = ({
                "test": {
                    "popouts": {
                        "hasCurrent": true,
                        "pinned": true
                    }
                }
            });
        DeviceActions.busy = false;
    }

    function test_sound_controls_and_settings_link() {
        const popup = createTemporaryObject(sound, test);
        verify(popup.implicitHeight > 100 && popup.implicitHeight < 600);
        const volume = findChild(popup, "quickOutputVolume");
        volume.value = 0.5;
        volume.moved();
        compare(NacreAudio.volume, 0.5);
        findChild(popup, "quickMicMute").clicked();
        compare(NacreAudio.micMuted, true);
        verify(!findChild(popup, "quickSettingsLink"));
        Visibilities.openDeviceSettings("audio");
        compare(Visibilities.settingsPage, "sound");
        compare(Visibilities.screens.test.dashboardTab, 4);
        verify(Visibilities.screens.test.dashboard);
        verify(!Visibilities.panels.test.popouts.hasCurrent);
        verify(!Visibilities.panels.test.popouts.pinned);
    }

    function test_connected_ap_updates_when_same_name_roams() {
        compare(groupedAPs.length, 1);
        compare(groupedAPs[0], secondAP);
        firstAP.active = true;
        secondAP.active = false;
        compare(groupedAPs[0], firstAP);
        firstAP.active = false;
        firstAP.strength = 10;
        compare(groupedAPs[0], secondAP);
        firstAP.strength = 90;
        secondAP.active = true;
    }

    function test_wifi_deduplicates_and_opens_network_settings() {
        const popup = createTemporaryObject(network, test);
        compare(popup.nearby.length, 2);
        compare(popup.nearby[0].ssid, "ab");
        verify(popup.nearby[0].active);
        compare(popup.nearby[0].strength, 30);
        const disconnect = findChild(popup, "connectedWifiAction");
        verify(disconnect);
        compare(disconnect.text, "Disconnect");
        disconnect.clicked();
        compare(DeviceActions.lastRequest.join("|"), "wifi-disconnect|wlan0");
        findChild(popup, "availableWifiAction").clicked();
        compare(DeviceActions.lastRequest.join("|"), "wifi-connect|Guest");
        findChild(popup, "quickWifiPower").clicked();
        compare(DeviceActions.lastRequest.join("|"), "wifi-radio|off");
        verify(!findChild(popup, "quickSettingsLink"));
        Visibilities.openDeviceSettings("network");
        compare(Visibilities.settingsPage, "network");
    }

    function test_bluetooth_shows_known_devices_and_links_settings() {
        const popup = createTemporaryObject(bluetooth, test);
        compare(popup.known.length, 1);
        compare(popup.known[0].name, "Headphones");
        findChild(popup, "quickBluetoothPower").clicked();
        compare(DeviceActions.lastRequest.join("|"), "bluetooth-power|off");
        verify(!findChild(popup, "quickSettingsLink"));
        Visibilities.openDeviceSettings("bluetooth");
        compare(Visibilities.settingsPage, "bluetooth");
    }

    name: "QuickDeviceControls"
    width: 700
    height: 700
    visible: true
    when: windowShown

    Component {
        id: sound

        AudioPopup {}
    }

    Component {
        id: network

        NetworkPopup {}
    }

    Component {
        id: bluetooth

        BluetoothPopup {}
    }

    QtObject {
        id: firstAP

        property string ssid: "Shared network"
        property bool active: false
        property int strength: 90
    }

    QtObject {
        id: secondAP

        property string ssid: "Shared network"
        property bool active: true
        property int strength: 30
    }
}
