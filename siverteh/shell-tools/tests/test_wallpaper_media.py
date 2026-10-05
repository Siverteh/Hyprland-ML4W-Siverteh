import importlib.util,json,os,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
from PIL import Image
spec=importlib.util.spec_from_file_location('wallpaper_media',Path(__file__).resolve().parents[1]/'wallpaper-media.py');media=importlib.util.module_from_spec(spec);spec.loader.exec_module(media)
class WallpaperMediaTests(unittest.TestCase):
 def test_static_and_animated_gif_have_distinct_identity_and_posters(self):
  with tempfile.TemporaryDirectory() as folder,patch.object(media,'CACHE',Path(folder)/'cache'):
   static=Path(folder)/'Still.png';Image.new('RGB',(32,24),'red').save(static)
   animated=Path(folder)/'Motion.gif';frames=[Image.new('RGB',(32,24),c) for c in ('red','blue')];frames[0].save(animated,save_all=True,append_images=frames[1:],duration=100,loop=0)
   self.assertFalse(media.describe(static)['dynamic']);item=media.describe(animated);self.assertTrue(item['dynamic']);self.assertTrue(item['animated']);self.assertNotEqual(item['path'],item['poster']);self.assertTrue(Path(item['poster']).is_file())
 def test_preferences_are_validated_private_and_preserve_other_fields(self):
  with tempfile.TemporaryDirectory() as folder,patch.object(media,'PREFS',Path(folder)/'picker.json'):
   media.preference({'layout':'hexagons'});media.preference({'kind':'dynamic'})
   self.assertEqual(media.settings()['layout'],'hexagons');self.assertEqual(os.stat(media.PREFS).st_mode&0o777,0o600)
   with self.assertRaises(ValueError):media.preference({'layout':'command-line'})
 def test_import_preserves_original_and_does_not_overwrite_names(self):
  with tempfile.TemporaryDirectory() as folder,patch.object(media,'LIBRARY',Path(folder)/'walls'):
   source=Path(folder)/'Example.png';Image.new('RGB',(32,24),'blue').save(source)
   first=media.import_files([str(source)]);second=media.import_files([str(source)])
   self.assertNotEqual(first,second);self.assertTrue(source.exists());self.assertTrue(Path(first[0]).exists())
 def test_failed_palette_commit_does_not_publish_media_state(self):
  with tempfile.TemporaryDirectory() as folder,patch.object(media,'STATE',Path(folder)/'state'),patch.object(media,'describe',return_value={'path':'video','poster':'poster'}),patch.object(media.subprocess,'run',side_effect=RuntimeError):
   with self.assertRaises(RuntimeError):media.select('video')
   self.assertFalse((media.STATE/'media.json').exists())
