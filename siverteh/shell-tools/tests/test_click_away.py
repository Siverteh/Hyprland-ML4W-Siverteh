import os,shutil,subprocess,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class ClickAwayTests(unittest.TestCase):
 def test_outside_click_geometry(self):
  runner=Path('/usr/lib/qt6/bin/qmltestrunner')
  if not runner.exists():self.skipTest('Qt Quick Test unavailable')
  with tempfile.TemporaryDirectory() as folder:
   path=Path(folder);shutil.copytree(ROOT/'tests/qml/fixtures',path/'fixtures')
   source=(ROOT.parent/'shell/modules/drawers/Interactions.qml').read_text().replace('import "root:/services"','import "fixtures"').replace('import "root:/config"','').replace('import "root:/modules/bar/popouts" as BarPopouts','').replace('import "root:/modules/osd" as Osd','').replace('import Quickshell','')
   for typename in ['ShellScreen','BarPopouts.Wrapper','PersistentProperties','Panels','Item']:source=source.replace('required property '+typename,'required property var')
   source=source[:source.index('    Osd.Interactions {')]+'}\n';(path/'Interactions.qml').write_text(source)
   (path/'fixtures/DesktopSettings.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject {property var data:({leftDrawer:true})}')
   (path/'fixtures/BorderConfig.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject {property int rounding:20}')
   with (path/'fixtures/qmldir').open('a') as f:f.write('\nsingleton DesktopSettings 1.0 DesktopSettings.qml\nsingleton BorderConfig 1.0 BorderConfig.qml\n')
   shutil.copy2(ROOT/'tests/click-away-qml/tst_click_away.qml',path/'tst_click_away.qml')
   result=subprocess.run([str(runner),'-input',str(path),'-o','-,txt'],capture_output=True,text=True,env=dict(os.environ,QT_QPA_PLATFORM='offscreen'),timeout=30)
   self.assertEqual(result.returncode,0,result.stdout+result.stderr);self.assertNotIn('QWARN',result.stdout+result.stderr)
