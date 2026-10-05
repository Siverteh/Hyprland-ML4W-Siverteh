import importlib.util,json,os,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
spec=importlib.util.spec_from_file_location('launcher_preferences',Path(__file__).resolve().parents[1]/'launcher-preferences.py');prefs=importlib.util.module_from_spec(spec);spec.loader.exec_module(prefs)
class LauncherPreferencesTests(unittest.TestCase):
 def test_favorites_and_hidden_updates_preserve_other_choices(self):
  with tempfile.TemporaryDirectory() as folder,patch.object(prefs,'PATH',Path(folder)/'launcher.json'):
   prefs.change('favorite',{'id':'one.desktop','enabled':True});prefs.change('hide',{'id':'two.desktop','enabled':True});prefs.change('favorite',{'id':'one.desktop','enabled':True})
   self.assertEqual(prefs.load(),{'favorites':['one.desktop'],'hidden':['two.desktop']});self.assertEqual(os.stat(prefs.PATH).st_mode&0o777,0o600)
   prefs.change('hide',{'id':'two.desktop','enabled':False});self.assertEqual(prefs.load()['hidden'],[])
 def test_invalid_preference_is_rejected_without_writes(self):
  with tempfile.TemporaryDirectory() as folder,patch.object(prefs,'PATH',Path(folder)/'launcher.json'):
   with self.assertRaises(ValueError):prefs.change('favorite',{'id':'bad\nname','enabled':True})
   self.assertFalse(prefs.PATH.exists())

 def test_malformed_existing_preferences_are_preserved(self):
  with tempfile.TemporaryDirectory() as folder,patch.object(prefs,'PATH',Path(folder)/'launcher.json'):
   original='{"favorites":42,"hidden":[]}'
   prefs.PATH.write_text(original)
   with self.assertRaises(ValueError):prefs.change('favorite',{'id':'one','enabled':True})
   self.assertEqual(prefs.PATH.read_text(),original)
