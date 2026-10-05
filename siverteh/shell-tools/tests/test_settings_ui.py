"""Exercise settings navigation and the shared wheel handler in native Qt."""
import os, shutil, subprocess, tempfile, unittest
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

class SettingsUITests(unittest.TestCase):
 def test_pages_and_shared_scrolling(self):
  runner=Path('/usr/lib/qt6/bin/qmltestrunner')
  if not runner.exists():self.skipTest('Qt Quick Test is unavailable')
  with tempfile.TemporaryDirectory() as directory:
   target=Path(directory);shutil.copytree(ROOT/'tests/qml/fixtures',target/'fixtures')
   source=(ROOT.parent/'shell/modules/dashboard/Settings.qml').read_text().replace('import "root:/widgets"','import "fixtures"').replace('import "root:/services"','').replace('import "root:/config"','').replace('import Quickshell','').replace('Quickshell.screens[0].height','1080')
   (target/'Settings.qml').write_text(source)
   shutil.copy2(ROOT.parent/'shell/widgets/FastScroll.qml',target/'fixtures/FastScroll.qml')
   (target/'fixtures/StateLayer.qml').write_text('import QtQuick\nMouseArea {anchors.fill:parent}')
   (target/'fixtures/DesktopSettings.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject {property var data:({});property string message:"";property var monitors:[{name:"eDP-1",width:1920,height:1080}];property bool pending:false;function set(key,value){} function request(args){}}')
   (target/'fixtures/Maintenance.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject {property var data:({});property string message:"";property bool busy:false;function refresh(){} function request(action){} function recover(action){}}')
   with (target/'fixtures/qmldir').open('a') as manifest:manifest.write('\nsingleton DesktopSettings 1.0 DesktopSettings.qml\nsingleton Maintenance 1.0 Maintenance.qml\n')
   shutil.copy2(ROOT/'tests/qml/tst_settings.qml',target/'tst_settings.qml')
   result=subprocess.run([str(runner),'-input',str(target),'-o','-,txt'],env=dict(os.environ,QT_QPA_PLATFORM='offscreen'),capture_output=True,text=True,timeout=30)
   self.assertEqual(result.returncode,0,result.stdout+result.stderr)
   self.assertNotIn('QWARN',result.stdout+result.stderr)
