"""Actual workspace page with fixture compositor commands and client objects."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from test_overview_ui import prepare_overview

ROOT = Path(__file__).resolve().parents[1]
SHELL = ROOT.parent / "shell"


class WorkspaceUITests(unittest.TestCase):
    def test_workspace_data_geometry_and_dispatch_guards(self):
        runner = Path("/usr/lib/qt6/bin/qmltestrunner")
        if not runner.exists():
            self.skipTest("Qt Quick Test unavailable")
        with tempfile.TemporaryDirectory() as folder:
            target = Path(folder)
            prepare_overview(target)
            fixtures = target / "fixtures"
            providers = {
                "Hyprland": 'property var clients:[];property int activeWsId:2;property string request:"";function dispatch(value){request=value}',
                "NacreIcons": 'function getDesktopEntry(name){return name==="chrome"?{name:"Browser"}:null}',
            }
            for name, source in providers.items():
                (fixtures / (name + ".qml")).write_text(
                    "pragma Singleton\nimport QtQuick\nQtObject{" + source + "}"
                )
            shutil.copy2(SHELL / "config/NacreBar.qml", fixtures / "NacreBar.qml")
            with (fixtures / "qmldir").open("a") as out:
                for name in [*providers, "NacreBar"]:
                    out.write(f"\nsingleton {name} 1.0 {name}.qml\n")
            colors = fixtures / "Colours.qml"
            colors.write_text(
                colors.read_text().replace(
                    '"m3onPrimary": "black",',
                    '"m3onPrimary": "black", "m3primaryContainer":"#334455", "m3onPrimaryContainer":"white",',
                )
            )
            source = (
                (SHELL / "modules/dashboard/NacreWorkspacePage.qml")
                .read_text()
                .replace("import Quickshell", "")
                .replace("import qs.widgets", 'import "fixtures"')
                .replace("import qs.services", "")
                .replace("import qs.config", "")
                .replace("import qs.utils", "")
                .replace(
                    "required property PersistentProperties visibilities",
                    "required property var visibilities",
                )
            )
            (target / "NacreWorkspacePage.qml").write_text(source)
            shutil.copy2(
                ROOT / "tests/workspace-qml/tst_workspace.qml",
                target / "tst_workspace.qml",
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
