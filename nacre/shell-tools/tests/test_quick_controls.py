from qml_source import install_foundation_interaction

"""Real popup controls and navigation, with fake devices to preserve live connections."""

import importlib.util
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("actions", ROOT / "device-actions.py")
actions = importlib.util.module_from_spec(spec)
spec.loader.exec_module(actions)


class QuickControlsTests(unittest.TestCase):
    def test_disconnect_is_bounded_to_a_valid_interface(self):
        self.assertEqual(
            actions.command("wifi-disconnect", "wlan0"),
            ["nmcli", "device", "disconnect", "wlan0"],
        )
        for interface in ["", "-all", "wlan0;reboot", "wlan0\n", "x" * 65]:
            with self.assertRaises(ValueError):
                actions.command("wifi-disconnect", interface)

    def test_network_status_ignores_ethernet_and_disconnected_wifi(self):
        with patch.object(
            actions.subprocess,
            "check_output",
            side_effect=[
                "enabled\n",
                "eth0:ethernet:connected\nwlan1:wifi:disconnected\nwlan0:wifi:connected\n",
            ],
        ):
            self.assertEqual(
                actions.network_status(), {"enabled": True, "interface": "wlan0"}
            )
        with patch.object(
            actions.subprocess,
            "check_output",
            side_effect=["disabled\n", "wlan0:wifi:disconnected\n"],
        ):
            self.assertEqual(
                actions.network_status(), {"enabled": False, "interface": ""}
            )

    def test_popups_and_settings_navigation_in_native_qt(self):
        runner = Path("/usr/lib/qt6/bin/qmltestrunner")
        if not runner.exists():
            self.skipTest("Qt Quick Test unavailable")
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory)
            shutil.copytree(ROOT / "tests/qml/fixtures", target / "fixtures")

            def adapt(source):
                return (
                    source.replace("import qs.widgets", 'import "fixtures"')
                    .replace(
                        "import qs.services",
                        "" if "import qs.widgets" in source else 'import "fixtures"',
                    )
                    .replace("import qs.config", "")
                    .replace("import Quickshell.Services.Pipewire", "")
                )

            for name in ["Audio", "Network", "Bluetooth"]:
                (target / (name + "Popup.qml")).write_text(
                    adapt(
                        (
                            ROOT.parent / "shell/modules/bar/popouts" / (name + ".qml")
                        ).read_text()
                    )
                )
            (target / "QuickList.qml").write_text(
                adapt(
                    (
                        ROOT.parent / "shell/modules/bar/popouts/QuickList.qml"
                    ).read_text()
                )
            )
            (target / "QuickSlider.qml").write_text(
                adapt(
                    (
                        ROOT.parent / "shell/modules/bar/popouts/QuickSlider.qml"
                    ).read_text()
                )
            )
            for name in ["ActionButton", "NacreInteraction"]:
                text = (
                    (ROOT.parent / "shell/widgets" / (name + ".qml"))
                    .read_text()
                    .replace("import qs.widgets", "")
                    .replace("import qs.services", "")
                    .replace("import qs.config", "")
                )
                (target / "fixtures" / (name + ".qml")).write_text(text)
            (target / "fixtures/NacreIcon.qml").write_text("import QtQuick\nText {}")
            (target / "fixtures/PwObjectTracker.qml").write_text(
                "import QtQuick\nQtObject {property var objects:[]}"
            )
            colors = (
                (target / "fixtures/Colours.qml")
                .read_text()
                .replace(
                    'm3primary: "cyan",',
                    'm3primary: "cyan", m3primaryContainer:"#303050",',
                )
            )
            (target / "fixtures/Colours.qml").write_text(colors)
            services = {
                "NacreAudio": 'property var sink:({ready:true,description:"Speakers"});property real volume:.7;property real micVolume:.4;property bool muted:false;property bool micMuted:false;property bool micAvailable:true;function setVolume(v){volume=v} function setMicVolume(v){micVolume=v} function toggleMute(){muted=!muted} function toggleMic(){micMuted=!micMuted}',
                "Pipewire": 'property var nodes:({values:[{isStream:false,isSink:true,description:"Speakers",name:"speaker"}]});property var defaultAudioSink:nodes.values[0];property var preferredDefaultAudioSink:null',
                "Network": 'property bool wifiEnabled:true;property string wifiInterface:"wlan0";property var active:({ssid:"ab"});property var networks:[{ssid:"ab",active:false,strength:90},{ssid:"Guest",active:false,strength:65},{ssid:"ab",active:true,strength:30}];readonly property var visibleNetworks:Wifi.group(networks)',
                "NacreBluetooth": 'property bool powered:true;property var devices:[{name:"Headphones",alias:"Headphones",address:"AA:BB:CC:DD:EE:FF",connected:true,paired:true,trusted:true},{name:"Unpaired",alias:"Unpaired",address:"00:11:22:33:44:55",connected:false,paired:false,trusted:false}]',
                "DeviceActions": 'property bool busy:false;property string message:"";property string lastAction:"";property var lastRequest:[];function request(a){lastRequest=a;lastAction=a[0]} function connectWifi(ssid){lastRequest=["wifi-connect",ssid]}',
                "Hyprland": 'property var focusedMonitor:({name:"test"})',
                "DesktopSettings": "property var data:({})",
            }
            for name, body in services.items():
                (target / "fixtures" / (name + ".qml")).write_text(
                    "pragma Singleton\nimport QtQuick\nQtObject {" + body + "}"
                )
            shutil.copy2(
                ROOT.parent / "shell/utils/scripts/wifi-networks.js",
                target / "wifi-networks.js",
            )
            path = target / "fixtures/Network.qml"
            path.write_text(
                path.read_text().replace(
                    "import QtQuick",
                    'import QtQuick\nimport "../wifi-networks.js" as Wifi',
                )
            )
            visibility = (
                (ROOT.parent / "shell/services/Visibilities.qml")
                .read_text()
                .replace("import Quickshell", "")
                .replace("Singleton {", "QtObject {")
                .replace(": PersistentProperties", "")
            )
            (target / "fixtures/Visibilities.qml").write_text(visibility)
            with (target / "fixtures/qmldir").open("a") as f:
                for name in [*services, "Visibilities"]:
                    f.write(f"\nsingleton {name} 1.0 {name}.qml")
                f.write(
                    "\nNacreIcon 1.0 NacreIcon.qml\nNacreInteraction 1.0 NacreInteraction.qml\nPwObjectTracker 1.0 PwObjectTracker.qml\n"
                )
            shutil.copy2(
                ROOT / "tests/qml/tst_quick_controls.qml",
                target / "tst_quick_controls.qml",
            )
            install_foundation_interaction(
                target / "fixtures", ROOT.parent / "shell/widgets"
            )
            result = subprocess.run(
                [str(runner), "-input", str(target), "-o", "-,txt"],
                env=dict(os.environ, QT_QPA_PLATFORM="offscreen"),
                capture_output=True,
                text=True,
                timeout=30,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn("QWARN", result.stdout + result.stderr)
