import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).parents[2]
spec = importlib.util.spec_from_file_location(
    "system_migration", ROOT / "tools/nacre_system_migration.py"
)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class NacreSystemMigrationTests(unittest.TestCase):
    def test_login_theme_and_timezone_move_without_changing_auth_or_preferences(self):
        with tempfile.TemporaryDirectory() as directory:
            prefix = Path(directory)
            config = prefix / "etc/siverteh-os/timezone.json"
            config.parent.mkdir(parents=True)
            settings = {"automatic": False, "confirmedTimezone": "America/Chicago"}
            config.write_text(json.dumps(settings))
            sddm = prefix / "etc/sddm.conf"
            sddm.write_text("[Autologin]\nSession=hyprland\n")
            old_theme = prefix / "usr/share/sddm/themes/siverteh"
            old_theme.mkdir(parents=True)
            (old_theme / "theme.conf").write_text("old")
            old_config = prefix / "etc/sddm.conf.d/90-siverteh-theme.conf"
            old_config.parent.mkdir()
            old_config.write_text("[Theme]\nCurrent=siverteh\n")
            result = m.apply(prefix, ROOT, run_system=False)
            self.assertFalse(result["automatic"])
            self.assertEqual(
                json.loads((prefix / "etc/nacre/timezone.json").read_text()), settings
            )
            self.assertEqual(sddm.read_text(), "[Autologin]\nSession=hyprland\n")
            self.assertIn(
                "Name=Nacre",
                (prefix / "usr/share/sddm/themes/nacre/metadata.desktop").read_text(),
            )
            self.assertIn("Current=nacre", old_config.read_text())
            self.assertTrue(old_theme.is_symlink())
            self.assertTrue((prefix / "usr/local/libexec/nacre-timezone.py").exists())
