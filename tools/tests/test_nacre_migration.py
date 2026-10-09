import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import subprocess

spec = importlib.util.spec_from_file_location(
    "nacre_migration", Path(__file__).parents[1] / "nacre_migration.py"
)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class NacreMigrationTests(unittest.TestCase):
    def test_merge_preserves_settings_palette_and_old_readers(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            desktop = home / ".config/siverteh-shell"
            desktop.mkdir(parents=True)
            (desktop / "desktop.json").write_text('{"scale":1.5}')
            cli = home / ".config/siverteh_shell"
            cli.mkdir()
            (cli / "cli.json").write_text('{"mode":"dark"}')
            manifest = m.apply(home)
            self.assertTrue(desktop.is_symlink())
            self.assertTrue(cli.is_symlink())
            self.assertEqual(
                (home / ".config/nacre/desktop.json").read_text(), '{"scale":1.5}'
            )
            self.assertEqual((cli / "cli.json").read_text(), '{"mode":"dark"}')
            self.assertEqual(m.plan(home), [])
            self.assertIsNone(m.apply(home))
            # Current data edits survive rollback: this is a namespace move, not data loss.
            (desktop / "desktop.json").write_text('{"scale":1}')
            m.rollback(manifest)
            self.assertFalse(desktop.is_symlink())
            self.assertFalse(cli.is_symlink())
            self.assertEqual((desktop / "desktop.json").read_text(), '{"scale":1}')
            self.assertEqual((cli / "cli.json").read_text(), '{"mode":"dark"}')
            m.rollback(manifest)

    def test_collision_refuses_every_move_before_mutation(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            old = home / ".config/siverteh-shell"
            new = home / ".config/nacre"
            old.mkdir(parents=True)
            new.mkdir()
            (old / "desktop.json").write_text("old")
            (new / "desktop.json").write_text("personal")
            with self.assertRaisesRegex(RuntimeError, "destination preserved"):
                m.apply(home)
            self.assertFalse(old.is_symlink())
            self.assertEqual((new / "desktop.json").read_text(), "personal")

    def test_virtual_environment_link_and_release_history_keep_their_targets(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            release = home / ".local/state/siverteh-os/releases/runtime"
            release.mkdir(parents=True)
            (release / "keep").write_text("runtime")
            runtime = home / ".local/share/siverteh-ai/shell-runtime"
            runtime.parent.mkdir(parents=True)
            runtime.symlink_to(release)
            manifest = m.apply(home)
            self.assertEqual((runtime / "keep").read_text(), "runtime")
            self.assertEqual(
                (home / ".local/share/nacre/palette-runtime/keep").read_text(),
                "runtime",
            )
            m.rollback(manifest)
            self.assertTrue(runtime.is_symlink())
            self.assertEqual((runtime / "keep").read_text(), "runtime")

    def test_collision_between_legacy_roots_is_found_before_either_moves(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            first = home / ".config/siverteh-shell"
            second = home / ".config/siverteh_shell"
            first.mkdir(parents=True)
            second.mkdir()
            (first / "cli.json").write_text("different")
            (second / "cli.json").write_text("personal")
            with self.assertRaisesRegex(RuntimeError, "destination preserved"):
                m.apply(home)
            self.assertFalse(first.is_symlink())
            self.assertFalse(second.is_symlink())
            self.assertFalse((home / ".config/nacre").exists())

    def test_power_alias_refuses_to_retire_original_without_new_inhibitor(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            unit = home / ".config/systemd/user/siverteh-manual-power.service"
            unit.parent.mkdir(parents=True)
            unit.write_text("legacy unit")
            with (
                patch(
                    "subprocess.run",
                    return_value=subprocess.CompletedProcess([], 0, "[]", ""),
                ) as run,
                patch("time.sleep"),
            ):
                with self.assertRaisesRegex(RuntimeError, "original lease preserved"):
                    m.install_service_aliases(home)
                self.assertFalse(
                    any("disable" in call.args[0] for call in run.call_args_list)
                )
                self.assertEqual(unit.read_text(), "legacy unit")

    def test_service_alias_is_installed_only_after_confirmed_power_lease(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            old = home / ".config/systemd/user/siverteh-manual-power.service"
            new = old.with_name("nacre-power-key.service")
            old.parent.mkdir(parents=True)
            old.write_text("legacy unit")
            new.write_text("new unit")
            result = subprocess.CompletedProcess(
                [],
                0,
                '[{"who":"Nacre-desktop","what":"handle-power-key","mode":"block"}]',
                "",
            )
            with (
                patch.object(m, "UNITS", {old.name: (new.name, m.digest(old))}),
                patch("subprocess.run", return_value=result) as run,
            ):
                m.install_service_aliases(home)
                self.assertTrue(old.is_symlink())
                self.assertEqual(old.resolve(), new)
                self.assertEqual(run.call_args_list[0].args[0][0], "systemd-inhibit")
