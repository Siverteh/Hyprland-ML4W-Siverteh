import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('configure', Path(__file__).parents[1] / 'configure.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ConfigurationTests(unittest.TestCase):
    def test_copy_install_is_repeatable_and_refuses_later_local_edits(self):
        with tempfile.TemporaryDirectory() as directory:
            root, home = Path(directory) / 'repo', Path(directory) / 'home'
            (root / 'bin').mkdir(parents=True)
            (root / 'hypr').mkdir()
            for name in ('siverteh-os-app', 'xdg-open'):
                (root / 'bin' / name).write_text('helper')
            source = root / 'hypr/hyprland.lua'
            source.write_text('current source')
            module.apply(home, root)
            self.assertEqual(module.plan(home, root)[0], [])
            target = home / '.config/hypr/hyprland.lua'
            target.write_text('personal edit')
            source.write_text('new source')
            with self.assertRaisesRegex(RuntimeError, 'Local edit preserved'):
                module.apply(home, root)
            self.assertEqual(target.read_text(), 'personal edit')

    def test_owned_symlink_migration_preserves_private_monitors_and_backup(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            root, old, home = base / 'repo', base / 'old', base / 'home'
            for directory in (root / 'hypr/conf', old / 'hypr/conf', root / 'bin', old / '.git', home / '.config'):
                directory.mkdir(parents=True)
            (old / 'hypr/conf/monitor.lua').write_text('host monitor override')
            (old / 'hypr/old.conf').write_text('retired')
            (root / 'hypr/conf/monitor.lua').write_text('generic fallback')
            for name in ('siverteh-os-app', 'xdg-open'):
                (root / 'bin' / name).write_text('helper')
            (home / '.config/hypr').symlink_to(old / 'hypr')
            with self.assertRaises(RuntimeError):
                module.apply(home, root)
            backup = module.apply(home, root, migrate=True)
            self.assertEqual((home / '.config/siverteh-shell/monitor.lua').read_text(), 'host monitor override')
            self.assertEqual((backup / '.config/hypr/old.conf').read_text(), 'retired')
            self.assertFalse((home / '.config/hypr/old.conf').exists())
            self.assertFalse((home / '.config/hypr').is_symlink())

    def test_removed_managed_file_is_backed_up_and_pruned_only_when_unmodified(self):
        with tempfile.TemporaryDirectory() as directory:
            root,home=Path(directory)/'repo',Path(directory)/'home'
            (root/'hypr').mkdir(parents=True);(root/'bin').mkdir()
            for name in ('siverteh-os-app','xdg-open'):(root/'bin'/name).write_text('helper')
            old=root/'hypr/retired.lua';old.write_text('owned old configuration')
            module.apply(home,root);old.unlink();backup=module.apply(home,root)
            self.assertFalse((home/'.config/hypr/retired.lua').exists())
            self.assertEqual((backup/'.config/hypr/retired.lua').read_text(),'owned old configuration')
