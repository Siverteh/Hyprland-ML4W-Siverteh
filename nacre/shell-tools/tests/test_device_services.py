"""Exercise actual independent service code with native dependency fixtures."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

from qml_source import remove_objects

ROOT = Path(__file__).resolve().parents[1]


class DeviceServiceTests(unittest.TestCase):
    def run_service(self, name):
        runner = Path("/usr/lib/qt6/bin/qmltestrunner")
        if not runner.exists():
            self.skipTest("Native Qt Quick Test unavailable")
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory)
            fixtures = target / "fixtures"
            fixtures.mkdir()
            definitions = {
                "Visibilities": 'property var screens:({});property var panels:({});property string settingsPage:"notifications"',
                "DesktopEntries": "property var applications:({values:[]})",
                "LauncherPreferences": "property var hidden:[]",
                "AppLaunch": "property var calls:[];function run(command,cwd){calls=[...calls,{command:command,cwd:cwd}]}",
                "DesktopSettings": "property var data:({dnd:false})",
                "NacreNotifications": "property bool expire:true;property int defaultExpireTimeout:5000",
                "Mpris": "property var players:({values:[]})",
                "Pipewire": "property var nodes:({values:[]});property var defaultAudioSink:null;property var defaultAudioSource:null",
                "Bluetooth": "property var devices:({values:[]});property var defaultAdapter:null",
            }
            for kind, body in definitions.items():
                (fixtures / (kind + ".qml")).write_text(
                    "pragma Singleton\nimport QtQuick\nQtObject {" + body + "}"
                )
            (fixtures / "PwObjectTracker.qml").write_text(
                "import QtQuick\nQtObject {property var objects:[]}"
            )
            (fixtures / "Process.qml").write_text(
                "import QtQuick\nQtObject {property var command:[];property var environment:({});property bool running:false;property QtObject stdout;property QtObject stderr;signal exited(int exitCode,int exitStatus);signal started();property bool stdinEnabled:false;property var writes:[];function write(text){writes=[...writes,text]}property int starts:0;onRunningChanged:if(running){starts++;Qt.callLater(()=>{if(running)started()})}}"
            )
            (fixtures / "StdioCollector.qml").write_text(
                'import QtQuick\nQtObject {property string text:"";signal streamFinished()}'
            )
            (fixtures / "SplitParser.qml").write_text(
                "import QtQuick\nQtObject {signal read(string data)}"
            )
            (fixtures / "qmldir").write_text(
                "singleton DesktopEntries 1.0 DesktopEntries.qml\nsingleton LauncherPreferences 1.0 LauncherPreferences.qml\nsingleton AppLaunch 1.0 AppLaunch.qml\nsingleton DesktopSettings 1.0 DesktopSettings.qml\nsingleton NacreNotifications 1.0 NacreNotifications.qml\nsingleton Visibilities 1.0 Visibilities.qml\nsingleton Mpris 1.0 Mpris.qml\nsingleton Pipewire 1.0 Pipewire.qml\nsingleton Bluetooth 1.0 Bluetooth.qml\nPwObjectTracker 1.0 PwObjectTracker.qml\nProcess 1.0 Process.qml\nStdioCollector 1.0 StdioCollector.qml\nSplitParser 1.0 SplitParser.qml\n"
            )
            (fixtures / "FileView.qml").write_text(
                'import QtQuick\nQtObject {property string path:"";property bool printErrors:false;signal loaded();function text(){return ""}function reload(){}}'
            )
            with (fixtures / "qmldir").open("a") as manifest:
                manifest.write("\nFileView 1.0 FileView.qml\n")
            if name == "NacreApps":
                shutil.copy2(
                    ROOT.parent / "shell/services/app-search.js",
                    target / "app-search.js",
                )
            if name == "NacreTime":
                (fixtures / "SystemClock.qml").write_text(
                    "import QtQuick\nQtObject {enum Precision {Seconds, Minutes} property int precision:SystemClock.Minutes;property bool enabled:true;property date date:new Date(2026,9,9,12,34,56);readonly property int hours:date.getHours();readonly property int minutes:date.getMinutes();readonly property int seconds:precision===SystemClock.Seconds?date.getSeconds():0}"
                )
                with (fixtures / "qmldir").open("a") as manifest:
                    manifest.write("\nSystemClock 1.0 SystemClock.qml\n")
            if name == "NacreNotifs":
                entry = (
                    ROOT.parent / "shell/services/NacreNotificationEntry.qml"
                ).read_text()
                (target / "NacreNotificationEntry.qml").write_text(
                    entry.replace("notification?.transient", "notification?.temporary")
                )
                (fixtures / "NotificationServer.qml").write_text(
                    "import QtQuick\nQtObject {property bool keepOnReload:false;property bool actionsSupported:false;property bool imageSupported:false;property bool persistenceSupported:false;property bool bodyMarkupSupported:false;signal notification(var notification)}"
                )
                with (fixtures / "qmldir").open("a") as manifest:
                    manifest.write("\nNotificationServer 1.0 NotificationServer.qml\n")
            if name == "NacreSystemUsage":
                shutil.copy2(
                    ROOT.parent / "shell/services/resource-data.js",
                    target / "resource-data.js",
                )
            source = (ROOT.parent / "shell/services" / (name + ".qml")).read_text()
            source = (
                source.replace("pragma Singleton", "")
                .replace("import Quickshell.Services.Pipewire", 'import "fixtures"')
                .replace(
                    "import Quickshell.Bluetooth as Bluez", 'import "fixtures" as Bluez'
                )
                .replace("import qs.config", 'import "fixtures"')
                .replace(
                    "import Quickshell.Services.Notifications", 'import "fixtures"'
                )
                .replace("import Quickshell.Services.Mpris", 'import "fixtures"')
                .replace("import Quickshell.Hyprland", "")
                .replace("import Quickshell.Io", 'import "fixtures"')
                .replace("import Quickshell", 'import QtQuick\nimport "fixtures"')
                .replace("Singleton {", "Item {")
                .replace('Quickshell.env("HOME")', '"/fixture"')
            )
            if name == "NacreNotifs":
                source = source.replace("notification.id", "notification.noticeId")
            source = remove_objects(source, r"\bIpcHandler\s*\{")
            source = remove_objects(source, r"\bGlobalShortcut\s*\{")
            (target / (name + ".qml")).write_text(source)
            shutil.copy2(
                ROOT / "tests/device-qml" / ("tst_" + name + ".qml"),
                target / "tst_service.qml",
            )
            result = subprocess.run(
                [str(runner), "-input", str(target), "-o", "-,txt"],
                env={**os.environ, "QT_QPA_PLATFORM": "offscreen"},
                capture_output=True,
                text=True,
                timeout=30,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn("QWARN", result.stdout + result.stderr)

    def test_audio_native_state_and_safe_writes(self):
        self.run_service("NacreAudio")

    def test_bluetooth_native_models_are_readonly_and_reactive(self):
        self.run_service("NacreBluetooth")

    def test_network_snapshot_publication_and_coalescing(self):
        self.run_service("NacreNetwork")

    def test_media_selection_capabilities_and_removed_manual_player(self):
        self.run_service("NacrePlayers")

    def test_resources_counter_math_missing_data_and_visible_sampling(self):
        self.run_service("NacreSystemUsage")

    def test_notifications_history_races_expiry_and_durable_actions(self):
        self.run_service("NacreNotifs")

    def test_application_rank_hidden_membership_and_safe_native_commands(self):
        self.run_service("NacreApps")

    def test_clock_civil_format_precision_and_enable(self):
        self.run_service("NacreTime")
