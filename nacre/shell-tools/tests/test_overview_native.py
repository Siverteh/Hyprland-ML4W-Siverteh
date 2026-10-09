"""Real Quickshell overview rendering and album clipping, beyond plain Qt mocks."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SHELL = ROOT.parent / "shell"


class OverviewNativeTests(unittest.TestCase):
    def test_actual_overview_renderer_and_album_circle(self):
        binary = shutil.which("quickshell")
        if not binary:
            self.skipTest("Quickshell unavailable")
        try:
            from PIL import Image
        except ImportError:
            self.skipTest("Pillow unavailable")
        wrapper = []
        if not os.environ.get("DISPLAY"):
            if not shutil.which("xvfb-run"):
                self.skipTest("OpenGL display unavailable")
            wrapper = ["xvfb-run", "-a"]
        with tempfile.TemporaryDirectory() as folder:
            target = Path(folder)
            for name in ("widgets", "services", "dashboard"):
                (target / name).mkdir()
            for name in (
                "NacreTokens",
                "NacreSurface",
                "NacreText",
                "NacreInteraction",
                "NacreIcon",
                "NacreClip",
                "FastScroll",
                "BrandLogo",
            ):
                shutil.copy2(
                    SHELL / "widgets" / (name + ".qml"),
                    target / "widgets" / (name + ".qml"),
                )
            shutil.copy2(
                SHELL / "modules/dashboard/NacreOverview.qml",
                target / "dashboard/NacreOverview.qml",
            )
            shutil.copytree(
                SHELL / "modules/dashboard/overview", target / "dashboard/overview"
            )
            poster = target / "cover.png"
            Image.new("RGB", (160, 160), "#28794d").save(poster)
            palette = {
                "m3surface": "#12171b",
                "m3surfaceContainer": "#27313b",
                "m3surfaceContainerHigh": "#303d47",
                "m3frame": "#354452",
                "m3onSurface": "#e3ebef",
                "m3onSurfaceVariant": "#a9b7c1",
                "m3outline": "#798e9b",
                "m3outlineVariant": "#43535f",
                "m3primary": "#76b1c4",
                "m3secondary": "#d8b790",
                "m3tertiary": "#a5bd8d",
                "m3onPrimary": "#102025",
            }
            providers = {
                "NacreColours": "property bool light:false;property var palette:"
                + json.dumps(palette),
                "DesktopSettings": "property var data:({animations:false})",
                "NacreTime": "property date date:new Date(2026,9,9,12,34);function format(v){return Qt.formatDateTime(date,v)}",
                "Weather": 'property real temperature:22;property string displayTemperature:"22°C";property string description:"Clear";property string icon:"sunny";property string location:"Fixture city";property bool stale:false',
                "NacreSystemUsage": "property real cpuPerc:.15;property real memPerc:.63;property real storagePerc:.37",
                "NacrePlayers": 'property QtObject active: QtObject {property string trackTitle:"Fixture track";property string trackArtist:"Artist";property string trackAlbum:"Album";property string identity:"Fixture";property string trackArtUrl:'
                + json.dumps(poster.as_uri())
                + ";property real position:120;property real length:400;property bool positionSupported:true;property bool lengthSupported:true;property bool isPlaying:false;property bool canControl:false;property bool canGoPrevious:false;property bool canTogglePlaying:false;property bool canGoNext:false;signal trackChanged();signal postTrackChanged()}",
            }
            for name, body in providers.items():
                (target / "services" / (name + ".qml")).write_text(
                    "pragma Singleton\nimport QtQuick\nQtObject {" + body + "}"
                )
            (target / "shell.qml").write_text("""import QtQuick
import Quickshell
import qs.dashboard
ShellRoot {FloatingWindow {visible:true;implicitWidth:894;implicitHeight:508
 Item {id:sheet;anchors.fill:parent
 Rectangle {anchors.fill:parent;color:"#10171b"}
 NacreOverview {id:overview;x:10;y:10;width:874;height:488;shouldUpdate:true}
 }
 Timer {interval:600;running:true;onTriggered:sheet.grabToImage(result=>{if(!result.saveToFile("capture.png"))throw new Error("capture failed");console.log("OVERVIEW_NATIVE_OK");Qt.quit();})}
}}""")
            environment = {
                **os.environ,
                "QT_QPA_PLATFORM": "offscreen",
                "QT_QUICK_BACKEND": "rhi",
                "QSG_RHI_BACKEND": "opengl",
                "QT_SCALE_FACTOR": "1",
                "QT_FONT_DPI": "96",
                "QT_LOGGING_RULES": "qml.debug=true;scene.debug=true",
                "XDG_CACHE_HOME": str(target / "cache"),
            }
            environment.pop("WAYLAND_DISPLAY", None)
            result = subprocess.run(
                [*wrapper, binary, "-p", str(target / "shell.qml")],
                cwd=target,
                env=environment,
                capture_output=True,
                text=True,
                timeout=20,
            )
            output = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, output)
            self.assertIn("OVERVIEW_NATIVE_OK", output)
            self.assertNotIn("ERROR", output)
            for line in output.splitlines():
                if "WARN" in line:
                    self.assertIn("does not support setting window masks", line)
            with Image.open(target / "capture.png") as capture:
                image = capture.convert("RGB")
                self.assertEqual(image.size, (894, 508))
                self.assertEqual(image.getpixel((781, 115)), (40, 121, 77))
                self.assertEqual(image.getpixel((704, 38)), (39, 49, 59))
                self.assertEqual(image.getpixel((11, 11)), (16, 23, 27))
            review = os.environ.get("NACRE_OVERVIEW_REVIEW")
            if review:
                shutil.copy2(target / "capture.png", review)
