"""Actual overview cards, contract providers and native Qt interaction tests."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

from qml_source import install_foundation_interaction

ROOT = Path(__file__).resolve().parents[1]
SHELL = ROOT.parent / "shell"


def prepare_overview(target):
    fixtures = target / "fixtures"
    shutil.copytree(ROOT / "tests/qml/fixtures", fixtures)
    install_foundation_interaction(fixtures, SHELL / "widgets")
    for name in ("NacreSurface", "NacreText", "FastScroll"):
        shutil.copy2(SHELL / "widgets" / (name + ".qml"), fixtures / (name + ".qml"))
    (fixtures / "NacreIcon.qml").write_text("import QtQuick\nText {}")
    (fixtures / "NacreClip.qml").write_text("import QtQuick\nRectangle {clip:true}")
    (fixtures / "BrandLogo.qml").write_text("import QtQuick\nRectangle {color:'white'}")
    (fixtures / "FileView.qml").write_text("""import QtQuick
QtObject {
 property string path:""
 property bool printErrors:false
 signal loaded()
 function text(){return path==='/proc/uptime' ? '9001 0' : 'PRETTY_NAME="Fixture Linux"'}
 function reload(){if(path)loaded()}
 onPathChanged:if(path)Qt.callLater(reload)
}""")
    providers = {
        "NacreWeather": 'property real temperature:22;property string displayTemperature:"22°C";property string description:"Clear";property string icon:"sunny";property string location:"Fixture city";property bool stale:false',
        "NacreTime": "property date date:new Date(2026,9,9,12,34);function format(value){return Qt.formatDateTime(date,value)}",
        "NacrePlayers": "property var active:null",
        "NacreSystemUsage": "property real cpuPerc:.15;property real memPerc:.63;property real storagePerc:.37",
    }
    with (fixtures / "qmldir").open("a") as manifest:
        for name in ("NacreIcon", "NacreClip", "BrandLogo", "FileView"):
            manifest.write(f"\n{name} 1.0 {name}.qml\n")
        for name, source in providers.items():
            (fixtures / (name + ".qml")).write_text(
                "pragma Singleton\nimport QtQuick\nQtObject {" + source + "}"
            )
            manifest.write(f"\nsingleton {name} 1.0 {name}.qml\n")
    for name in ("NacreOverview",):
        source = (SHELL / "modules/dashboard" / (name + ".qml")).read_text()
        (target / (name + ".qml")).write_text(
            source.replace("import qs.widgets", 'import "fixtures"')
        )
    (target / "overview").mkdir()
    for path in (SHELL / "modules/dashboard/overview").iterdir():
        if path.suffix == ".js":
            shutil.copy2(path, target / "overview" / path.name)
            continue
        source = (
            path.read_text()
            .replace("import Quickshell.Io", "")
            .replace("import Quickshell", "")
        )
        source = source.replace("import qs.widgets", 'import "../fixtures"').replace(
            "import qs.services", ""
        )
        source = source.replace('Quickshell.env("USER")', '"fixture-user"')
        (target / "overview" / path.name).write_text(source)


class OverviewUITests(unittest.TestCase):
    def test_production_cards_and_calendar_under_local_civil_time(self):
        runner = Path("/usr/lib/qt6/bin/qmltestrunner")
        if not runner.exists():
            self.skipTest("Qt Quick Test unavailable")
        with tempfile.TemporaryDirectory() as folder:
            target = Path(folder)
            prepare_overview(target)
            shutil.copy2(
                ROOT / "tests/overview-qml/tst_overview.qml",
                target / "tst_overview.qml",
            )
            result = subprocess.run(
                [str(runner), "-input", str(target), "-o", "-,txt"],
                env={
                    **os.environ,
                    "QT_QPA_PLATFORM": "offscreen",
                    "TZ": "America/Chicago",
                },
                capture_output=True,
                text=True,
                timeout=30,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn("QWARN", result.stdout + result.stderr)
