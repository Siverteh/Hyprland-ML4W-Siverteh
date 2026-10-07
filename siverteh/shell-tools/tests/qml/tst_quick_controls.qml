import QtQuick
import QtTest
import "fixtures"

TestCase {
    id: test
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
    function init() {
        Visibilities.screens = ({
                test: {
                    dashboard: false
                }
            });
        Visibilities.panels = ({
                test: {
                    popouts: {
                        hasCurrent: true,
                        pinned: true
                    }
                }
            });
        DeviceActions.busy = false;
    }
    function test_sound_controls_and_settings_link() {
        const popup = createTemporaryObject(sound, test);
        verify(popup.implicitHeight > 100 && popup.implicitHeight < 600);
        const volume = findChild(popup, "quickOutputVolume");
        volume.value = .5;
        volume.moved();
        compare(Audio.volume, .5);
        findChild(popup, "quickMicMute").clicked();
        compare(Audio.micMuted, true);
        verify(!findChild(popup, "quickSettingsLink"));
        Visibilities.openDeviceSettings("audio");
        compare(Visibilities.settingsPage, "sound");
        compare(Visibilities.screens.test.dashboardTab, 4);
        verify(Visibilities.screens.test.dashboard);
        verify(!Visibilities.panels.test.popouts.hasCurrent);
        verify(!Visibilities.panels.test.popouts.pinned);
    }
    function test_wifi_deduplicates_and_opens_network_settings() {
        const popup = createTemporaryObject(network, test);
        compare(popup.nearby.length, 2);
        compare(popup.nearby[0].ssid, "ab");
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
}
