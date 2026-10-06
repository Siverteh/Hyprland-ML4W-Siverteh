import os,shutil,subprocess,tempfile,unittest
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
class WallpaperPickerUITests(unittest.TestCase):
 def test_filter_search_layouts_and_hex_hit_testing(self):
  runner=Path('/usr/lib/qt6/bin/qmltestrunner')
  if not runner.exists():self.skipTest('Qt Quick Test unavailable')
  with tempfile.TemporaryDirectory() as folder:
   target=Path(folder);shutil.copytree(ROOT/'tests/qml/fixtures',target/'fixtures');Image.new('RGB',(32,24),'blue').save(target/'poster.png');Image.new('RGB',(32,24),'green').save(target/'second.png');shutil.copy2(ROOT.parent/'shell/modules/launcher/WallpaperBackdrop.qml',target/'WallpaperBackdrop.qml')
   presentation=(ROOT.parent/'shell/services/ThemePresentation.qml').read_text().replace('pragma Singleton','').replace('import "root:/utils"','').replace('import Quickshell.Io','').replace('import Quickshell','').replace('Singleton {','Item {')
   (target/'ThemePresentation.qml').write_text('\n'.join(line for line in presentation.splitlines() if 'FileView {' not in line))
   for name in ('WallpaperGallery','WallpaperHex'):
    source=(ROOT.parent/'shell/modules/launcher'/ (name+'.qml')).read_text().replace('import "root:/widgets"','import "fixtures"').replace('import "root:/services"','').replace('import Quickshell.Io','').replace('import Quickshell','').replace('required property PersistentProperties visibilities','required property var visibilities').replace('Quickshell.screens[0].width','1920').replace('Quickshell.screens[0].height','1200')
    source='\n'.join(line for line in source.splitlines() if 'IpcHandler {' not in line);(target/(name+'.qml')).write_text(source)
   shutil.copy2(ROOT.parent/'shell/widgets/FastScroll.qml',target/'fixtures/FastScroll.qml')
   (target/'fixtures/MaterialIcon.qml').write_text('import QtQuick\nText {}')
   (target/'fixtures/Wallpapers.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject {property bool loading:false;property string current:"one";property string error:"";property var preferences:({kind:"static",layout:"carousel"});property string browsed:"";property var list:[{path:"one",name:"Expedition33 Monolith",poster:"'+str(target/'poster.png')+'",dynamic:false},{path:"two",name:"Hollow Knight",poster:"'+str(target/'poster.png')+'",dynamic:false},{path:"three",name:"Final Fantasy Video",poster:"'+str(target/'poster.png')+'",dynamic:true}];function browse(path){browsed=path;current=path} function setWallpaper(path){browse(path)} function commitSelection(){} function pickFiles(){} function addFiles(paths){} function preference(value){preferences=Object.assign({},preferences,value)}}')
   (target/'fixtures/ActionButton.qml').write_text((target/'fixtures/ActionButton.qml').read_text().replace('property bool selected:', 'property bool compact:false;property bool selected:'))
   with (target/'fixtures/qmldir').open('a') as manifest:manifest.write('\nMaterialIcon 1.0 MaterialIcon.qml\nsingleton Wallpapers 1.0 Wallpapers.qml\n')
   shutil.copy2(ROOT/'tests/wallpaper-qml/tst_wallpapers.qml',target/'tst_wallpapers.qml')
   result=subprocess.run([str(runner),'-input',str(target),'-o','-,txt'],capture_output=True,text=True,env=dict(os.environ,QT_QPA_PLATFORM='offscreen'),timeout=30)
   self.assertEqual(result.returncode,0,result.stdout+result.stderr);self.assertNotIn('QWARN',result.stdout+result.stderr)
