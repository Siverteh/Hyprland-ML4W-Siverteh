import importlib.util,json,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
def module(name,file):
 spec=importlib.util.spec_from_file_location(name,ROOT/file);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
info=module('lockinfo','lock-info.py');config=module('lockconfig','lock-config.py');devices=module('devices','device-actions.py');weather=module('weather','weather.py')
class LockAndDeviceTests(unittest.TestCase):
 def test_notification_privacy_is_enforced_again_after_cache_read(self):
  data={'count':1,'notifications':[{'app':'Mail','summary':'Private title','body':'Private body'}]}
  text=info.label('notifications',data,{})
  self.assertNotIn('Private',text);self.assertIn('Mail',text)
  self.assertIn('Private title',info.label('notifications',data,{'lockNotificationContents':True}))
  self.assertEqual(info.label('notifications',data,{'lockNotifications':False}),'')
 def test_untrusted_metadata_is_escaped_for_pango(self):
  text=info.label('media',{'media':{'title':'<span foreground="red">Oops</span>','artist':'A & B'}},{})
  self.assertNotIn('<span',text);self.assertIn('&lt;span',text);self.assertIn('A &amp; B',text)
 def test_render_respects_preferences_and_has_no_unlock_action(self):
  colors=json.loads((ROOT/'reference-style.json').read_text())['colours']
  output=config.render(colors,'/tmp/wallpaper.png',{'lockMedia':False,'lockWeather':False},Path('/tmp/lock-info.py'))
  self.assertNotIn('skip_next',output);self.assertNotIn('weather\n',output);self.assertIn('Notifications',info.label('notifications',{},{}));self.assertIn('input-field',output)
  self.assertNotIn('{{',output);self.assertNotIn('unlock-session',output)
  with self.assertRaises(ValueError):config.render(colors,'/tmp/evil\nlabel {}',{},Path('/tmp/helper.py'))
 def test_device_names_are_arguments_and_actions_are_bounded(self):
  self.assertEqual(devices.command('wifi-connect','$(anything); space')[-1],'$(anything); space')
  self.assertIn('--ask',devices.command('wifi-connect','WiFi'))
  with self.assertRaises(ValueError):devices.command('bluetooth-connect','AA:BB:CC;anything')
  with self.assertRaises(ValueError):devices.command('shell','anything')
 def test_weather_failure_preserves_cache_timestamp(self):
  with tempfile.TemporaryDirectory() as folder:
   home=Path(folder);cache=home/'weather.json';cache.write_text(json.dumps({'checked':123,'description':'Overcast','temperature':10}))
   with patch.object(weather,'HOME',home),patch.object(weather,'CACHE',cache),patch.object(weather,'fetch_json',side_effect=TimeoutError):data=weather.refresh()
   self.assertEqual(data['checked'],123);self.assertTrue(data['stale']);self.assertEqual(data['temperature'],10)
