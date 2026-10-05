"""Native category/search/navigation behavior with production QML and a fixture app index."""
import os,shutil,subprocess,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class LauncherUITests(unittest.TestCase):
 def test_browsing_and_search(self):
  runner=Path('/usr/lib/qt6/bin/qmltestrunner')
  if not runner.exists():self.skipTest('Qt Quick Test unavailable')
  with tempfile.TemporaryDirectory() as directory:
   target=Path(directory);shutil.copytree(ROOT/'tests/qml/fixtures',target/'fixtures')
   source=(ROOT.parent/'shell/modules/launcher/AppGrid.qml').read_text().replace('import "root:/widgets"','import "fixtures"').replace('import "root:/services"','').replace('import "root:/config"','').replace('import Quickshell.Io','').replace('import Quickshell','').replace('required property PersistentProperties visibilities','required property var visibilities').replace('Quickshell.screens[0].width','1920').replace('Quickshell.screens[0].height','1200').replace('Quickshell.iconPath(tile.modelData.icon)','""')
   source='\n'.join(line for line in source.splitlines() if 'IpcHandler {' not in line)
   (target/'AppGrid.qml').write_text(source);shutil.copy2(ROOT.parent/'shell/modules/launcher/launcher.js',target/'launcher.js');shutil.copy2(ROOT.parent/'shell/widgets/FastScroll.qml',target/'fixtures/FastScroll.qml')
   fixtures={'Apps':'property var all:[{id:"editor",name:"Editor",categories:["Development"],icon:""},{id:"music",name:"Music",categories:["AudioVideo"],icon:""},{id:"browser",name:"Browser",categories:["Network"],icon:""}];readonly property var list:all.filter(a=>!LauncherPreferences.hidden.includes(a.id));function fuzzyQuery(q){return list.filter(a=>a.name.toLowerCase().includes(q.toLowerCase()))} function launch(app){}',
    'LauncherPreferences':'property var favorites:[];property var hidden:[];property string error:"";property bool ready:true;function update(action,id,enabled){const key=action===\"favorite\"?\"favorites\":\"hidden\";let rows=this[key].filter(x=>x!==id);if(enabled)rows.push(id);this[key]=rows;}',
    'DesktopActions':'property var list:[{name:"Settings",description:"Desktop settings",action:"settings",icon:"settings"},{name:"Power menu",description:"Power controls",action:"power",icon:"power"}];function execute(action,value){}'}
   for name,body in fixtures.items():(target/'fixtures'/ (name+'.qml')).write_text('pragma Singleton\nimport QtQuick\nQtObject {'+body+'}')
   (target/'fixtures/ScriptModel.qml').write_text('import QtQuick\nListModel {property var values:[];onValuesChanged:{clear();for(const entry of values)append({modelData:entry})}}')
   (target/'fixtures/MaterialIcon.qml').write_text('import QtQuick\nText {}')
   with (target/'fixtures/qmldir').open('a') as manifest:
    for name in fixtures:manifest.write('\nsingleton '+name+' 1.0 '+name+'.qml')
    manifest.write('\nScriptModel 1.0 ScriptModel.qml\nMaterialIcon 1.0 MaterialIcon.qml\n')
   shutil.copy2(ROOT/'tests/launcher-qml/tst_launcher.qml',target/'tst_launcher.qml')
   result=subprocess.run([str(runner),'-input',str(target),'-o','-,txt'],capture_output=True,text=True,env=dict(os.environ,QT_QPA_PLATFORM='offscreen'),timeout=30)
   self.assertEqual(result.returncode,0,result.stdout+result.stderr);self.assertNotIn('QWARN',result.stdout+result.stderr)
