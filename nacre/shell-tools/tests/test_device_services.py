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
                "import QtQuick\nQtObject {property var command:[];property var environment:({});property bool running:false;property QtObject stdout;property QtObject stderr;signal exited(int exitCode,int exitStatus);property int starts:0;onRunningChanged:if(running) starts++}"
            )
            (fixtures / "StdioCollector.qml").write_text(
                'import QtQuick\nQtObject {property string text:"";signal streamFinished()}'
            )
            (fixtures / "SplitParser.qml").write_text(
                "import QtQuick\nQtObject {signal read(string data)}"
            )
            (fixtures / "qmldir").write_text(
                "singleton Pipewire 1.0 Pipewire.qml\nsingleton Bluetooth 1.0 Bluetooth.qml\nPwObjectTracker 1.0 PwObjectTracker.qml\nProcess 1.0 Process.qml\nStdioCollector 1.0 StdioCollector.qml\nSplitParser 1.0 SplitParser.qml\n"
            )
            source = (ROOT.parent / "shell/services" / (name + ".qml")).read_text()
            source = (
                source.replace("pragma Singleton", "")
                .replace("import Quickshell.Services.Pipewire", 'import "fixtures"')
                .replace(
                    "import Quickshell.Bluetooth as Bluez", 'import "fixtures" as Bluez'
                )
                .replace("import Quickshell.Io", 'import "fixtures"')
                .replace("import Quickshell", "import QtQuick")
                .replace("Singleton {", "Item {")
                .replace('Quickshell.env("HOME")', '"/fixture"')
            )
            source = remove_objects(source, r"\bIpcHandler\s*\{")
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
