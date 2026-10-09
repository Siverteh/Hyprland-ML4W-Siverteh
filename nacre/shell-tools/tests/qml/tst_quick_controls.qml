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
        NacreAudio.writes = 0;
        DesktopSettings.writes = [];
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

    function test_display_never_changes_devices_or_history_and_rejects_stale_rows() {
        const wifi = createTemporaryObject(network, test);
        const bt = createTemporaryObject(bluetooth, test);
        const audio = createTemporaryObject(sound, test);
        const previous = DeviceActions.lastRequest.join("|");
        verify(!wifi.activate({
            bssid: "AA:BB:CC:DD:EE:99",
            ssid: "Missing",
            active: false
        }));
        verify(!bt.activate({
            address: "AA:BB:CC:DD:EE:99",
            connected: false
        }));
        compare(DeviceActions.lastRequest.join("|"), previous);
        DeviceActions.busy = true;
        verify(!wifi.activate(wifi.nearby[0]));
        verify(!bt.activate(bt.known[0]));
        compare(DeviceActions.lastRequest.join("|"), previous);
        DeviceActions.busy = false;
        verify(bt.activate(bt.known[0]));
        compare(DeviceActions.lastRequest.join("|"), "bluetooth-disconnect|AA:BB:CC:DD:EE:FF");
        verify(!audio.chooseOutput({
            ready: true,
            audio: {},
            isSink: true
        }));
    }
    function test_audio_backend_changes_never_write_and_slider_user_action_does() {
        const audio = createTemporaryObject(sound, test);
        compare(NacreAudio.writes, 0);
        NacreAudio.volume = .42;
        compare(findChild(audio, "quickOutputVolume").value, .42);
        compare(NacreAudio.writes, 0);
        const slider = findChild(audio, "quickOutputVolume");
        slider.value = .6;
        slider.moved();
        compare(NacreAudio.writes, 1);
        compare(NacreAudio.volume, .6);
    }
    function test_every_route_and_closing_retention_unload_reversal() {
        DesktopSettings.data = {
            animations: true
        };
        const popup = createTemporaryObject(assembly, test);
        for (const name of ["audio", "network", "bluetooth", "notifications", "battery", "calendar"]) {
            popup.currentName = name;
            popup.hasCurrent = true;
            tryVerify(() => popup.currentItem !== null, 500);
            verify(popup.targetWidth >= 150 && popup.targetWidth <= 670);
            tryVerify(() => popup.height > 0, 300);
            verify(popup.currentItem.enabled);
            popup.hasCurrent = false;
            verify(!popup.enabled);
            verify(!popup.pinned);
            verify(popup.currentItem !== null);
            const width = popup.width;
            wait(40);
            compare(popup.width, width);
            popup.hasCurrent = true;
            wait(220);
            verify(popup.currentItem !== null && popup.height > 0);
            popup.hasCurrent = false;
            tryCompare(popup, "height", 0, 400);
            compare(popup.currentItem, null);
        }
        popup.currentName = "toString";
        popup.hasCurrent = true;
        verify(!popup.hasCurrent);
        compare(popup.currentItem, null);
    }
    function test_history_user_only_controls_and_pinned_escape() {
        NacreNotifs.retained = [
            {
                expanded: false
            }
        ];
        NacreNotifs.clears = 0;
        DesktopSettings.writes = [];
        const popup = createTemporaryObject(assembly, test);
        popup.currentName = "notifications";
        popup.hasCurrent = true;
        popup.pinned = true;
        tryVerify(() => popup.currentItem !== null && popup.focus, 400);
        compare(NacreNotifs.clears, 0);
        compare(DesktopSettings.writes.length, 0);
        findChild(popup.currentItem, "quickDnd").clicked();
        compare(DesktopSettings.writes[0].join("|"), "dnd|true");
        findChild(popup.currentItem, "quickClearHistory").clicked();
        compare(NacreNotifs.clears, 1);
        keyClick(Qt.Key_Escape);
        verify(!popup.hasCurrent);
        verify(!popup.pinned);
        NacreNotifs.retained = [];
    }
    function test_reduced_motion_unloads_without_lingering_view() {
        DesktopSettings.data = {
            animations: false
        };
        const popup = createTemporaryObject(assembly, test);
        popup.currentName = "audio";
        popup.hasCurrent = true;
        verify(popup.currentItem !== null);
        popup.hasCurrent = false;
        compare(popup.height, 0);
        compare(popup.currentItem, null);
    }
    Component {
        id: assembly
        NacrePopupPanel {
            screen: ({
                    name: "test",
                    height: 1000
                })
        }
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
