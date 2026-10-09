"""Exercise the real handle's delayed reveal and click behavior using Qt."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class EdgeHandleTests(unittest.TestCase):
    def test_hover_reveals_but_only_click_activates(self):
        runner = Path("/usr/lib/qt6/bin/qmltestrunner")
        if not runner.exists():
            self.skipTest("Qt Quick Test unavailable")
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory)
            shutil.copytree(ROOT / "tests/qml/fixtures", target / "fixtures")
            source = (ROOT.parent / "shell/widgets/EdgeMenuHandle.qml").read_text()
            source = (
                source.replace("import qs.services", 'import "fixtures"')
                .replace("import qs.config", "")
                .replace("import qs.widgets", "")
            )
            (target / "EdgeMenuHandle.qml").write_text(source)
            (target / "fixtures/NacreIcon.qml").write_text("import QtQuick\nText {}\n")
            (target / "fixtures/DesktopSettings.qml").write_text(
                "pragma Singleton\nimport QtQuick\nQtObject { property var data:({animations:false}) }"
            )
            with (target / "fixtures/qmldir").open("a") as f:
                f.write(
                    "\nNacreIcon 1.0 NacreIcon.qml\nsingleton DesktopSettings 1.0 DesktopSettings.qml\n"
                )
            (target / "tst_handle.qml").write_text("""import QtQuick
import QtTest
TestCase {
    name: "EdgeHandle"
    width: 300; height: 300; visible: true; when: windowShown
    Component { id: scene; EdgeMenuHandle { x: 80; y: 80; property int activations: 0; onClicked: activations++ } }
    function test_hover_click_and_grace_period() {
        const handle=createTemporaryObject(scene, this);
        verify(handle);
        mouseMove(this, 10, 10);
        mouseMove(handle, 20, 18);
        wait(80); verify(!handle.shown); compare(handle.activations, 0);
        tryCompare(handle, "shown", true, 500); compare(handle.activations, 0);
        mouseClick(handle, 20, 18); compare(handle.activations, 1);
        mouseMove(this, 10, 10); wait(100); verify(handle.shown);
        tryCompare(handle, "shown", false, 500);
    }
}""")
            result = subprocess.run(
                [str(runner), "-input", str(target), "-o", "-,txt"],
                env=dict(os.environ, QT_QPA_PLATFORM="offscreen"),
                capture_output=True,
                text=True,
                timeout=15,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn("QWARN", result.stdout + result.stderr)
