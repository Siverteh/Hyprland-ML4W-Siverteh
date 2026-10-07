from qml_source import remove_objects

"""Exercise settings navigation and the shared wheel handler in native Qt."""
import re
import os, shutil, subprocess, tempfile, unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class SettingsUITests(unittest.TestCase):
    def test_pages_and_shared_scrolling(self):
        runner = Path("/usr/lib/qt6/bin/qmltestrunner")
        if not runner.exists():
            self.skipTest("Qt Quick Test is unavailable")
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory)
            shutil.copytree(ROOT / "tests/qml/fixtures", target / "fixtures")

            def adapted(path, imports="fixtures"):
                return (
                    path.read_text()
                    .replace("import qs.widgets", 'import "' + imports + '"')
                    .replace("import qs.services", "")
                    .replace("import qs.config", "")
                    .replace("import Quickshell.Io", "")
                    .replace("import Quickshell.Services.Pipewire", "")
                    .replace("import Quickshell", "")
                    .replace("Quickshell.screens[0].height", "1080")
                    .replace("Quickshell.screens[0].width", "1920")
                )

            source = adapted(ROOT.parent / "shell/modules/dashboard/Settings.qml")
            source = remove_objects(source, r"\bIpcHandler\s*\{")
            (target / "Settings.qml").write_text(source)
            (target / "DesktopControls.qml").write_text(
                adapted(ROOT.parent / "shell/modules/dashboard/DesktopControls.qml")
            )
            pages = target / "settings"
            pages.mkdir()
            for path in (ROOT.parent / "shell/modules/dashboard/settings").glob(
                "*.qml"
            ):
                (pages / path.name).write_text(adapted(path, "../fixtures"))
            preview = (
                adapted(ROOT.parent / "shell/lock-preview.qml")
                .replace('import "widgets"', 'import "fixtures"')
                .replace('import "services"', "")
                .replace("ShellRoot {", "Item {")
                .replace("FloatingWindow {", "Rectangle {")
            )
            preview = re.sub(
                r'title\s*:\s*"Siverteh lock screen preview"',
                'property string title: "Siverteh lock screen preview"',
                preview,
            )
            preview = remove_objects(preview, r"\bProcess\s*\{\s*id\s*:\s*reader\b")
            preview = remove_objects(preview, r"\bTimer\s*\{\s*interval\s*:\s*3000\b")
            (target / "LockPreview.qml").write_text(preview)
            services = {
                "Visibilities": 'property string settingsPage:"appearance";function openSettings(page){settingsPage=page}',
                "TimezoneSettings": 'property var status:({timezone:"UTC",localTime:"12:34",automatic:false,installed:false});property string message:"";property bool busy:false;function refresh(){} function change(kind,value){}',
                "Time": 'function format(pattern){return "12:34"}',
                "Wallpapers": 'property string poster:"";property string preview:"";property string current:"";property var list:[];property var preferences:({rotationEnabled:true,rotationMinutes:30,rotationKind:"all",rotationShuffle:true,palettePreset:"wallpaper"});property var palettePresets:[{id:"ocean",name:"Ocean",group:"vivid",surface:"102030",swatches:["aabbcc","ccbbaa","abcabc"]}];property bool themeBusy:false;property bool rotationReady:true;property string error:"";function preference(value){preferences=Object.assign({},preferences,value)} function advanceRotation(manual){} function setWallpaper(path){}',
                "AppLaunch": "function run(command){}",
                "DesktopActions": "function execute(action){}",
                "Network": "property var active:null;property var networks:[]",
                "Bluetooth": "property bool powered:false;property var devices:[]",
                "DeviceActions": 'property bool busy:false;property string message:"";function request(args){} function connectWifi(ssid){}',
                "Weather": 'property string description:"";property string location:"";property string error:"";property string displayTemperature:"";function reload(){}',
                "Notifs": "property var list:[];function clearHistory(){} function dismiss(entry){}",
                "Pipewire": "property var nodes:({values:[]});property var defaultAudioSink:null;property var defaultAudioSource:null;property var preferredDefaultAudioSink:null;property var preferredDefaultAudioSource:null",
            }
            for name, body in services.items():
                (target / "fixtures" / (name + ".qml")).write_text(
                    "pragma Singleton\nimport QtQuick\nQtObject {" + body + "}"
                )
            (target / "fixtures/PwObjectTracker.qml").write_text(
                "import QtQuick\nQtObject {property var objects:[]}"
            )
            (target / "fixtures/ShLogo.qml").write_text(
                "import QtQuick\nItem {implicitWidth:26;implicitHeight:26}"
            )
            (target / "fixtures/MaterialIcon.qml").write_text("import QtQuick\nText {}")
            with (target / "fixtures/qmldir").open("a") as manifest:
                for name in services:
                    manifest.write("\nsingleton " + name + " 1.0 " + name + ".qml")
                manifest.write(
                    "\nPwObjectTracker 1.0 PwObjectTracker.qml\nShLogo 1.0 ShLogo.qml\nMaterialIcon 1.0 MaterialIcon.qml\n"
                )
            shutil.copy2(
                ROOT.parent / "shell/widgets/FastScroll.qml",
                target / "fixtures/FastScroll.qml",
            )
            (target / "fixtures/StateLayer.qml").write_text(
                "import QtQuick\nMouseArea {anchors.fill:parent}"
            )
            (target / "fixtures/DesktopSettings.qml").write_text(
                'pragma Singleton\nimport QtQuick\nQtObject {property var data:({});property string message:"";property var monitors:[{name:"eDP-1",width:1920,height:1080}];property bool pending:false;function set(key,value){} function request(args){}}'
            )
            (target / "fixtures/Maintenance.qml").write_text(
                'pragma Singleton\nimport QtQuick\nQtObject {property var data:({});property string message:"";property bool busy:false;function refresh(){} function request(action){} function recover(action){}}'
            )
            with (target / "fixtures/qmldir").open("a") as manifest:
                manifest.write(
                    "\nsingleton DesktopSettings 1.0 DesktopSettings.qml\nsingleton Maintenance 1.0 Maintenance.qml\n"
                )
            shutil.copy2(
                ROOT / "tests/qml/tst_settings.qml", target / "tst_settings.qml"
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
