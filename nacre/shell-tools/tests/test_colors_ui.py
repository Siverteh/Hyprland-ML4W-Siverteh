"""Native Colors studio controls, sizing, previews and explicit Apply dispatch."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from qml_source import install_foundation_interaction

ROOT = Path(__file__).parents[1]
SHELL = ROOT.parent / "shell"


class ColorsUITests(unittest.TestCase):
    def test_native_view_routes_and_bounds(self):
        runner = Path("/usr/lib/qt6/bin/qmltestrunner")
        if not runner.exists():
            self.skipTest("Qt Quick Test unavailable")
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory)
            fixtures = target / "fixtures"
            shutil.copytree(ROOT / "tests/qml/fixtures", fixtures)
            install_foundation_interaction(fixtures, SHELL / "widgets")
            for name in (
                "NacreText",
                "NacreIcon",
                "NacreSurface",
                "ActionButton",
                "FastScroll",
                "NacreTextField",
            ):
                s = (
                    (SHELL / "widgets" / f"{name}.qml")
                    .read_text()
                    .replace("import qs.services", 'import "."')
                )
                (fixtures / f"{name}.qml").write_text(s)
            for name in (
                "NacreColorsView",
                "NacreThemePreview",
                "NacreColorSample",
                "NacreAccentTarget",
            ):
                s = (
                    (SHELL / "modules/colors" / f"{name}.qml")
                    .read_text()
                    .replace("import qs.widgets", 'import "fixtures"')
                    .replace("import qs.services", 'import "fixtures"')
                    .replace("import Quickshell\n", "")
                )
                (target / f"{name}.qml").write_text(s)
            colors = json.loads(
                (ROOT / "tests/orient-gallery/palettes.json").read_text()
            )["night-city"]["dark-natural"]["colours"]
            body = """property var options:({mode:"dark",personality:"natural",backgroundFromWallpaper:false,overrides:{},brightness:0,saturation:1,hour:12,workspaceColors:false});property var preview:({id:"preview",name:"Night city",thumbnail:"",palette:{colours:COLORS,source:{candidates:[]},roleSources:{},accessibility:{textPasses:true,minimumTextContrast:4.52,warnings:[],text:[]}},comparisons:[]});property var library:[];property var favorites:[];property var history:[];property bool ready:true;property bool previewBusy:false;property bool actionBusy:false;property bool applied:false;property string error:"";property string status:"";property string exportDirectory:"";property var actions:[];function change(v){options=Object.assign({},options,v)}function choose(path){}function useFavorite(id){}function useHistory(item){}function setRole(role,value){let n=Object.assign({},options.overrides);if(value)n[role]=value;else delete n[role];change({overrides:n})}function action(name){if(ready && !previewBusy && !actionBusy)actions=[...actions,name]}function close(){actions=[...actions,"close"]}""".replace(
                "COLORS", json.dumps(colors)
            )
            (fixtures / "NacreColorsApp.qml").write_text(
                "pragma Singleton\nimport QtQuick\nQtObject{" + body + "}"
            )
            with (fixtures / "qmldir").open("a") as stream:
                stream.write(
                    "\nsingleton NacreColorsApp 1.0 NacreColorsApp.qml\nNacreIcon 1.0 NacreIcon.qml\n"
                )
            (fixtures / "BrandLogo.qml").write_text(
                "import QtQuick\nItem{property color primary;property color secondary;property color tertiary;property color highlight;property color background;property color foreground;property bool motionEnabled:false}"
            )
            (target / "tst_colors.qml").write_text("""import QtQuick
import QtTest
import "fixtures"
TestCase {id:test;name:"ColorsStudio";width:1300;height:1000;visible:true;when:windowShown
 Component{id:studio;NacreColorsView{width:1180;height:780}}
 function test_resize_and_preview_controls_are_read_only(){
  const view=createTemporaryObject(studio,test);wait(30);
  const initial=NacreColorsApp.actions.length;
  compare(findChild(view,"sourcePersonality"),null);
  const styles=findChild(view,"colorStyleControls");
  const appearance=findChild(view,"appearanceControls");
  verify(appearance.y>=styles.y+styles.height+12);
  compare(findChild(view,"darkModeButton").parent,appearance);
  compare(findChild(view,"lightModeButton").parent,appearance);
  const background=findChild(view,"wallpaperBackgroundSwitch");
  mouseClick(background,20,background.height/2);
  compare(NacreColorsApp.options.backgroundFromWallpaper,true);
  compare(NacreColorsApp.options.personality,"natural");compare(NacreColorsApp.actions.length,initial);
  findChild(view,"popPersonality").clicked();compare(NacreColorsApp.options.personality,"pop");compare(NacreColorsApp.actions.length,initial);
  for(const w of [740,960,1180]){view.width=w;wait(10);const canvas=findChild(view,"colorsCanvas");verify(canvas.width>400);verify(canvas.x+canvas.width<=view.width+.1);}
 }
 function test_explicit_actions_only_and_busy_guard(){
  const view=createTemporaryObject(studio,test);wait(30);const initial=NacreColorsApp.actions.length;
  NacreColorsApp.previewBusy=true;NacreColorsApp.action("apply");compare(NacreColorsApp.actions.length,initial);
  NacreColorsApp.previewBusy=false;NacreColorsApp.action("apply");compare(NacreColorsApp.actions[initial],"apply");
  view.page="compare";wait(10);view.page="accessibility";wait(10);compare(NacreColorsApp.actions.length,initial+1);
 }
}
""")
            result = subprocess.run(
                [str(runner), "-input", str(target), "-o", "-,txt"],
                env={**os.environ, "QT_QPA_PLATFORM": "offscreen"},
                capture_output=True,
                text=True,
                timeout=30,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn("QWARN", result.stdout + result.stderr)
