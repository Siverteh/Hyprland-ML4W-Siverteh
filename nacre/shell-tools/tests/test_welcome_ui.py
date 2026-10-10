"""Native Welcome navigation, controls, bounded layout and keyboard dismissal."""

import os
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from qml_source import install_foundation_interaction

ROOT = Path(__file__).parents[1]
SHELL = ROOT.parent / "shell"


class WelcomeUITests(unittest.TestCase):
    def test_native_routes_startup_and_responsive_footer(self):
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
                "NacreScrollBar",
            ):
                text = (
                    (SHELL / "widgets" / (name + ".qml"))
                    .read_text()
                    .replace("import qs.services", 'import "."')
                )
                (fixtures / (name + ".qml")).write_text(text)
                if name in ("NacreIcon", "NacreScrollBar"):
                    with (fixtures / "qmldir").open("a") as stream:
                        stream.write(f"\n{name} 1.0 {name}.qml\n")
            (target / "branding").mkdir()
            shutil.copyfile(
                SHELL / "branding/LogoData.js", target / "branding/LogoData.js"
            )
            (fixtures / "BrandLogo.qml").write_text(
                (SHELL / "widgets/BrandLogo.qml")
                .read_text()
                .replace("import qs.services", 'import "."')
            )
            palette = json.loads(
                (ROOT / "tests/orient-gallery/palettes.json").read_text()
            )["night-city"][
                "light-natural"
                if os.environ.get("NACRE_WELCOME_LIGHT")
                else "dark-natural"
            ]["colours"]
            roles = {"m3" + key: "#" + value for key, value in palette.items()}
            (fixtures / "NacreColours.qml").write_text(
                "pragma Singleton\nimport QtQuick\nQtObject{property bool light:"
                + ("true" if os.environ.get("NACRE_WELCOME_LIGHT") else "false")
                + ";property var palette:"
                + json.dumps(roles)
                + "}"
            )
            (fixtures / "NacreWelcomeApp.qml").write_text("""pragma Singleton
import QtQuick
QtObject { property string page:"home";property string error:"";property bool busy:false;
 property var data:({preferences:{showAtLogin:true},available:{ai:false,brain:false}});
 property var actions:[];
 function route(name){actions=[...actions,name]} function link(name){actions=[...actions,"link:"+name]}
 function setStartup(value){data=Object.assign({},data,{preferences:{showAtLogin:value}})}
 function close(){actions=[...actions,"close"]}
}""")
            with (fixtures / "qmldir").open("a") as stream:
                stream.write(
                    "\nBrandLogo 1.0 BrandLogo.qml\nsingleton NacreWelcomeApp 1.0 NacreWelcomeApp.qml\n"
                )
            for name in ("NacreWelcomeView", "NacreWelcomeRow"):
                text = (
                    (SHELL / "modules/welcome" / (name + ".qml"))
                    .read_text()
                    .replace("import qs.services", 'import "fixtures"')
                    .replace("import qs.widgets", 'import "fixtures"')
                )
                (target / (name + ".qml")).write_text(text)
            shutil.copyfile(
                SHELL / "modules/welcome/welcome-catalog.js",
                target / "welcome-catalog.js",
            )
            (target / "tst_welcome.qml").write_text("""import QtQuick
import QtTest
import "fixtures"
TestCase {id:test;name:"Welcome";width:1200;height:900;visible:true;when:windowShown
 Component{id:studio;NacreSurface{width:1000;height:680;color:NacreTokens.body;NacreWelcomeView{id:main;anchors.fill:parent;objectName:"welcomeView"}}}
 function test_routes_keyboard_and_responsive_footer(){
  const preview=createTemporaryObject(studio,test);const view=findChild(preview,"welcomeView");wait(200);
  const canvas=findChild(view,"welcomeCanvas"); const footer=findChild(view,"welcomeFooter");
  verify(canvas.y+canvas.height< footer.y);verify(footer.y+footer.height<=view.height);
  const prefix=Qt.application.arguments.find(a=>a.startsWith("welcome-preview="));
  if(prefix){let saved=false;verify(preview.grabToImage(result=>{saved=result.saveToFile(prefix.slice(16)+"-wide.png")}));tryVerify(()=>saved,3000)}
  findChild(view,"welcomeColors").clicked();compare(NacreWelcomeApp.actions[0],"colors");
  findChild(view,"welcomePage_shortcuts").clicked();compare(NacreWelcomeApp.page,"shortcuts");wait(20);
  verify(canvas.contentHeight>canvas.height);
  findChild(view,"welcomePage_apps").clicked();compare(NacreWelcomeApp.page,"apps");
  if(prefix){wait(100);let saved=false;verify(preview.grabToImage(result=>{saved=result.saveToFile(prefix.slice(16)+"-apps.png")}));tryVerify(()=>saved,3000)}
  findChild(view,"welcomePage_help").clicked();compare(NacreWelcomeApp.page,"help");
  preview.width=672;preview.height=440;wait(30);verify(canvas.height>100);
  verify(footer.y+footer.height<=view.height);verify(findChild(view,"welcomeDone").x>=0);
  if(prefix){NacreWelcomeApp.page="home";wait(100);let saved=false;verify(preview.grabToImage(result=>{saved=result.saveToFile(prefix.slice(16)+"-narrow.png")}));tryVerify(()=>saved,3000)}
  const startup=findChild(view,"welcomeStartupToggle");mouseClick(startup,15,startup.height/2);
  compare(NacreWelcomeApp.data.preferences.showAtLogin,false);
  view.forceActiveFocus();keyClick(Qt.Key_Escape);compare(NacreWelcomeApp.actions[NacreWelcomeApp.actions.length-1],"close");
 }
}""")
            test_file = target / "tst_welcome.qml"
            prefix = (
                "welcome-preview=" + os.environ["NACRE_WELCOME_PREVIEW"]
                if os.environ.get("NACRE_WELCOME_PREVIEW")
                else ""
            )
            test_file.write_text(
                test_file.read_text().replace(
                    'const prefix=Qt.application.arguments.find(a=>a.startsWith("welcome-preview="));',
                    "const prefix=" + json.dumps(prefix) + ";",
                )
            )
            result = subprocess.run(
                [
                    str(runner),
                    "-input",
                    str(target / "tst_welcome.qml"),
                ],
                env={**os.environ, "QT_QPA_PLATFORM": "offscreen"},
                capture_output=True,
                text=True,
                timeout=30,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
