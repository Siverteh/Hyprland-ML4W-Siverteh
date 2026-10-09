"""Run the production top trigger with real Qt hover entry/motion events."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class TopHoverTests(unittest.TestCase):
    def test_title_boundary_and_dismissal_reentry(self):
        runner = Path("/usr/lib/qt6/bin/qmltestrunner")
        if not runner.exists():
            self.skipTest("Qt Quick Test unavailable")
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            source = (
                (ROOT.parent / "shell/modules/topbar/NacreHeaderTrigger.qml")
                .read_text()
                .replace("import qs.services", 'import "."')
            )
            (folder / "NacreHeaderTrigger.qml").write_text(source)
            (folder / "Trigger.qml").write_text("""import QtQuick
import "."
Item {
 width:1920; height:100
 property bool clickMenus:false
 property var screen:({name:"test",width:1920,height:1200})
 property QtObject visibility:QtObject {property bool dashboard:false;property bool session:false;property bool launcher:false;property bool dashboardPinned:false;property string edgeMenu:""}
 NacreHeaderTrigger {anchors.horizontalCenter:parent.horizontalCenter;screen:parent.screen;visibility:parent.visibility;clickMenus:parent.clickMenus}
}""")
            helper = (
                (ROOT.parent / "shell/services/NacreHoverIntent.qml")
                .read_text()
                .replace("import Quickshell", "")
                .replace("Singleton {", "QtObject {")
            )
            (folder / "NacreHoverIntent.qml").write_text(helper)
            (folder / "NacreHyprland.qml").write_text(
                'pragma Singleton\nimport QtQuick\nQtObject {property var focusedMonitor:({name:"test"}); property var activeClient:null}'
            )
            (folder / "DesktopSettings.qml").write_text(
                "pragma Singleton\nimport QtQuick\nQtObject {property var data:({frameWidth:10})}"
            )
            (folder / "Visibilities.qml").write_text(
                "pragma Singleton\nimport QtQuick\nQtObject {property var panels:({})}"
            )
            (folder / "qmldir").write_text(
                "singleton NacreHoverIntent 1.0 NacreHoverIntent.qml\nsingleton NacreHyprland 1.0 NacreHyprland.qml\nsingleton DesktopSettings 1.0 DesktopSettings.qml\nsingleton Visibilities 1.0 Visibilities.qml\n"
            )
            (folder / "tst_trigger.qml").write_text("""import QtQuick
import QtTest
import "."
TestCase {
    width:1920; height:200; visible:true; when:windowShown; name:"TopHover"
    Component { id:scene; Trigger {} }
    function test_lower_entry_title_and_reentry() {
        const view=createTemporaryObject(scene,this);
        mouseMove(view,960,80); mouseMove(view,960,40); wait(30);
        verify(!view.visibility.dashboard);
        mouseMove(view,960,24); verify(view.visibility.dashboard);
        NacreHoverIntent.dismiss(view.screen); view.visibility.dashboard=false;
        mouseMove(view,961,23); verify(!view.visibility.dashboard);
        mouseMove(view,960,40); mouseMove(view,960,24); verify(view.visibility.dashboard);
    }
}""")
            result = subprocess.run(
                [str(runner), "-input", str(folder), "-o", "-,txt"],
                env=dict(os.environ, QT_QPA_PLATFORM="offscreen"),
                capture_output=True,
                text=True,
                timeout=15,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn("QWARN", result.stdout + result.stderr)
