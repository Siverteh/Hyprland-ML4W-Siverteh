import importlib.util
from pathlib import Path
import json
import tempfile
import unittest

spec = importlib.util.spec_from_file_location(
    "configure", Path(__file__).parents[1] / "configure.py"
)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ConfigurationTests(unittest.TestCase):
    def test_copy_install_is_repeatable_and_refuses_later_local_edits(self):
        with tempfile.TemporaryDirectory() as directory:
            root, home = Path(directory) / "repo", Path(directory) / "home"
            (root / "bin").mkdir(parents=True)
            (root / "hypr").mkdir()
            for name in ("siverteh-os-app", "xdg-open"):
                (root / "bin" / name).write_text("helper")
            source = root / "hypr/hyprland.lua"
            source.write_text("current source")
            module.apply(home, root)
            self.assertEqual(module.plan(home, root)[0], [])
            target = home / ".config/hypr/hyprland.lua"
            target.write_text("personal edit")
            source.write_text("new source")
            with self.assertRaisesRegex(RuntimeError, "Local edit preserved"):
                module.apply(home, root)
            self.assertEqual(target.read_text(), "personal edit")

    def test_app_routes_scope_preserves_unrelated_edits_and_their_manifest(self):
        with tempfile.TemporaryDirectory() as directory:
            root, home = Path(directory) / "repo", Path(directory) / "home"
            (root / "bin").mkdir(parents=True)
            (root / "hypr").mkdir()
            for name in ("siverteh-os-app", "xdg-open"):
                (root / "bin" / name).write_text("old route")
            (root / "hypr/hypridle.conf").write_text("original idle")
            module.apply(home, root)
            manifest = home / ".local/state/siverteh-os/configuration.json"
            before = json.loads(manifest.read_text())[".config/hypr/hypridle.conf"]
            (home / ".config/hypr/hypridle.conf").write_text("personal idle choice")
            (root / "bin/siverteh-os-app").write_text("new route")
            module.apply(home, root, app_routes_only=True)
            self.assertEqual(
                (home / ".local/bin/siverteh-os-app").read_text(), "new route"
            )
            self.assertEqual(
                (home / ".config/hypr/hypridle.conf").read_text(),
                "personal idle choice",
            )
            self.assertEqual(
                json.loads(manifest.read_text())[".config/hypr/hypridle.conf"], before
            )
            module.apply(home, root, app_routes_only=True)
            self.assertEqual(
                json.loads(manifest.read_text())[".config/hypr/hypridle.conf"], before
            )
            with self.assertRaisesRegex(RuntimeError, "Local edit preserved"):
                module.plan(home, root)

    def test_owned_symlink_migration_preserves_private_monitors_and_backup(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            root, old, home = base / "repo", base / "old", base / "home"
            for directory in (
                root / "hypr/conf",
                old / "hypr/conf",
                root / "bin",
                old / ".git",
                home / ".config",
            ):
                directory.mkdir(parents=True)
            (old / "hypr/conf/monitor.lua").write_text("host monitor override")
            (old / "hypr/old.conf").write_text("retired")
            (root / "hypr/conf/monitor.lua").write_text("generic fallback")
            for name in ("siverteh-os-app", "xdg-open"):
                (root / "bin" / name).write_text("helper")
            (home / ".config/hypr").symlink_to(old / "hypr")
            with self.assertRaises(RuntimeError):
                module.apply(home, root)
            backup = module.apply(home, root, migrate=True)
            self.assertEqual(
                (home / ".config/siverteh-shell/monitor.lua").read_text(),
                "host monitor override",
            )
            self.assertEqual((backup / ".config/hypr/old.conf").read_text(), "retired")
            self.assertFalse((home / ".config/hypr/old.conf").exists())
            self.assertFalse((home / ".config/hypr").is_symlink())

    def test_uwsm_environment_is_deployed_and_drift_protected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "repo"
            home = Path(directory) / "home"
            (root / "uwsm").mkdir(parents=True)
            (root / "bin").mkdir()
            for name in ("siverteh-os-app", "xdg-open"):
                (root / "bin" / name).write_text("helper")
            (root / "uwsm/env").write_text("export XCURSOR_SIZE=24\n")
            (root / "uwsm/env-hyprland").write_text("export HYPRCURSOR_SIZE=24\n")
            module.apply(home, root)
            self.assertEqual(module.plan(home, root)[0], [])
            (home / ".config/uwsm/env").write_text("personal environment")
            (root / "uwsm/env").write_text("export XCURSOR_SIZE=32\n")
            with self.assertRaisesRegex(RuntimeError, "Local edit preserved"):
                module.apply(home, root)

    def test_managed_fish_link_migration_preserves_personal_files(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            root = base / "repo"
            home = base / "home"
            old = base / "legacy/fish"
            for path in (
                root / "fish/functions",
                root / "bin",
                old / "functions",
                home / ".config",
                home / ".local/state/siverteh-os",
            ):
                path.mkdir(parents=True)
            for name in ("siverteh-os-app", "xdg-open"):
                (root / "bin" / name).write_text("helper")
            (root / "fish/functions/fish_title.fish").write_text("owned title")
            (old / "functions/fish_title.fish").write_text("owned title")
            (old / "config.fish").write_text("personal setup")
            (home / ".config/fish").symlink_to(old)
            manifest = {
                ".config/fish/functions/fish_title.fish": module.digest(
                    old / "functions/fish_title.fish"
                )
            }
            (home / ".local/state/siverteh-os/configuration.json").write_text(
                json.dumps(manifest)
            )
            with self.assertRaises(RuntimeError):
                module.plan(home, root)
            backup = module.apply(home, root, migrate=True)
            self.assertFalse((home / ".config/fish").is_symlink())
            self.assertEqual(
                (home / ".config/fish/config.fish").read_text(), "personal setup"
            )
            self.assertEqual(
                (backup / ".config/fish/config.fish").read_text(), "personal setup"
            )
            self.assertEqual((old / "config.fish").read_text(), "personal setup")

    def test_removed_managed_file_is_backed_up_and_pruned_only_when_unmodified(self):
        with tempfile.TemporaryDirectory() as directory:
            root, home = Path(directory) / "repo", Path(directory) / "home"
            (root / "hypr").mkdir(parents=True)
            (root / "bin").mkdir()
            for name in ("siverteh-os-app", "xdg-open"):
                (root / "bin" / name).write_text("helper")
            old = root / "hypr/retired.lua"
            old.write_text("owned old configuration")
            module.apply(home, root)
            old.unlink()
            backup = module.apply(home, root)
            self.assertFalse((home / ".config/hypr/retired.lua").exists())
            self.assertEqual(
                (backup / ".config/hypr/retired.lua").read_text(),
                "owned old configuration",
            )


class IdleMigrationTests(unittest.TestCase):
    def test_idle_migration_preserves_policy_and_other_drift_protection(self):
        with tempfile.TemporaryDirectory() as directory:
            root, home = Path(directory) / "repo", Path(directory) / "home"
            (root / "bin").mkdir(parents=True)
            (root / "hypr").mkdir()
            (root / "tools/defaults").mkdir(parents=True)
            for name in ("siverteh-os-app", "xdg-open"):
                (root / "bin" / name).write_text("helper")
            source = root / "hypr/hypridle.conf"
            source.write_text("original")
            module.apply(home, root)
            target = home / ".config/hypr/hypridle.conf"
            target.write_text("manual locking only")
            source.write_text(module.IDLE_WRAPPER)
            (root / "tools/defaults/hypridle.conf").write_text("factory policy")
            with self.assertRaisesRegex(RuntimeError, "Local edit preserved"):
                module.plan(home, root)
            backup = module.apply(home, root, migrate_idle=True)
            self.assertEqual(
                (home / ".config/siverteh-shell/hypridle.local.conf").read_text(),
                "manual locking only",
            )
            self.assertEqual(
                (backup / ".config/hypr/hypridle.conf").read_text(),
                "manual locking only",
            )
            self.assertEqual(module.plan(home, root)[0], [])
            (home / ".local/bin/xdg-open").write_text("another personal edit")
            with self.assertRaisesRegex(RuntimeError, "Local edit preserved"):
                module.plan(home, root, migrate_idle=True)

    def test_conflicting_private_idle_policy_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            root, home = Path(directory) / "repo", Path(directory) / "home"
            (root / "hypr").mkdir(parents=True)
            (root / "hypr/hypridle.conf").write_text(module.IDLE_WRAPPER)
            (home / ".config/hypr").mkdir(parents=True)
            (home / ".config/hypr/hypridle.conf").write_text("manual policy")
            (home / ".config/siverteh-shell").mkdir()
            (home / ".config/siverteh-shell/hypridle.local.conf").write_text(
                "different policy"
            )
            with self.assertRaisesRegex(RuntimeError, "Private idle policy differs"):
                module.plan(home, root, migrate_idle=True)
