"""Actual media/performance pages with native Qt controls and service contracts."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

from test_overview_ui import prepare_overview

ROOT = Path(__file__).resolve().parents[1]
SHELL = ROOT.parent / "shell"


def prepare_pages(target):
    prepare_overview(target)
    fixtures = target / "fixtures"
    (fixtures / "Players.qml").write_text(
        "pragma Singleton\nimport QtQuick\nQtObject {property var list:[];property var active:null;property var manualActive:null;onManualActiveChanged:if(manualActive)active=manualActive}"
    )
    (fixtures / "SystemUsage.qml").write_text(
        'pragma Singleton\nimport QtQuick\nQtObject {property real cpuPerc:.15;property real cpuTemp:23;property real gpuTemp:NaN;property real gpuPerc:0;property bool gpuUsageAvailable:false;property real memPerc:.48;property int memUsed:15309210;property int memTotal:32191283;property real storagePerc:.52;property int storageUsed:190840832;property int storageTotal:367001600;property string loadAverage:".10 .20 .30";property string kernel:"Fixture kernel"}'
    )
    (fixtures / "ActionButton.qml").write_text(
        (SHELL / "widgets/ActionButton.qml")
        .read_text()
        .replace("import qs.services", 'import "."')
    )
    for name in ("NacreMediaPage", "NacrePerformancePage"):
        source = (SHELL / "modules/dashboard" / (name + ".qml")).read_text()
        source = source.replace("import Quickshell.Services.Mpris", "").replace(
            "import Quickshell", ""
        )
        source = source.replace("import qs.widgets", 'import "fixtures"').replace(
            "import qs.services", ""
        )
        source = source.replace(
            "required property PersistentProperties visibilities",
            "required property var visibilities",
        )
        for enum_name, value in (("None", "0"), ("Track", "1"), ("Playlist", "2")):
            source = source.replace("MprisLoopState." + enum_name, value)
        (target / (name + ".qml")).write_text(source)
    (target / "media").mkdir()
    for path in (SHELL / "modules/dashboard/media").iterdir():
        if path.suffix == ".js":
            shutil.copy2(path, target / "media" / path.name)
        else:
            source = (
                path.read_text()
                .replace("import qs.widgets", 'import "../fixtures"')
                .replace("import qs.services", "")
            )
            (target / "media" / path.name).write_text(source)


class MediaPerformanceUITests(unittest.TestCase):
    def test_control_transactions_resource_data_and_layout(self):
        runner = Path("/usr/lib/qt6/bin/qmltestrunner")
        if not runner.exists():
            self.skipTest("Qt Quick Test unavailable")
        with tempfile.TemporaryDirectory() as folder:
            target = Path(folder)
            prepare_pages(target)
            shutil.copy2(
                ROOT / "tests/media-performance-qml/tst_pages.qml",
                target / "tst_pages.qml",
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
