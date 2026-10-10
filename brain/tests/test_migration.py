"""Brain naming migration preserves private content and rejects collisions."""

import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location(
    "brain_migrate", ROOT / "brain/migrate.py"
)
migration = importlib.util.module_from_spec(spec)
spec.loader.exec_module(migration)


class BrainMigrationTests(unittest.TestCase):
    def test_content_permissions_aliases_idempotence_and_rollback(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            for old, _ in migration.DIRECTORIES:
                path = home / old
                if path.suffix == ".json":
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_text('{"enabled":true}')
                    path.chmod(0o600)
                else:
                    path.mkdir(parents=True, exist_ok=True)
                    (path / "evidence.md").write_bytes(b"Keep exactly these bytes\n")
            registration = home / ".config/obsidian/obsidian.json"
            registration.parent.mkdir(parents=True, exist_ok=True)
            registration.write_text(
                '{"vaults":{"id":{"path":"'
                + str(home / "Documents/Siverteh-Brain")
                + '","keep":true}}}'
            )
            original_registration = registration.read_bytes()
            journal = migration.apply(home)
            for old, new in migration.DIRECTORIES:
                self.assertTrue((home / old).is_symlink())
                self.assertEqual((home / old).resolve(), (home / new).resolve())
                if (home / new).is_dir():
                    self.assertEqual(
                        (home / new / "evidence.md").read_bytes(),
                        b"Keep exactly these bytes\n",
                    )
                else:
                    self.assertEqual((home / new).stat().st_mode & 0o777, 0o600)
            self.assertIsNone(migration.apply(home))
            migration.rollback(journal)
            self.assertEqual(registration.read_bytes(), original_registration)
            for old, new in migration.DIRECTORIES:
                self.assertTrue((home / old).exists())
                self.assertFalse((home / old).is_symlink())
                self.assertFalse((home / new).exists())

    def test_different_destination_or_local_unit_edit_is_preserved(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            for name, text in [
                ("Siverteh-Brain", "older"),
                ("Nacre-Brain", "personal edit"),
            ]:
                path = home / "Documents" / name
                path.mkdir(parents=True)
                (path / "note.md").write_text(text)
            with self.assertRaisesRegex(RuntimeError, "Conflicting"):
                migration.apply(home)
            self.assertEqual(
                (home / "Documents/Nacre-Brain/note.md").read_text(), "personal edit"
            )
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            path = home / ".config/systemd/user/siverteh-observatory-brain.service"
            path.parent.mkdir(parents=True)
            path.write_text("my custom command")
            with self.assertRaisesRegex(RuntimeError, "Locally edited"):
                migration.plan(home)
            self.assertEqual(path.read_text(), "my custom command")

    def test_canonical_cli_opens_ui_and_preserves_legacy_vault_override(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            ui = home / ".local/bin/nacre-brain-ui"
            ui.parent.mkdir(parents=True)
            ui.write_text('#!/bin/sh\nprintf "%s" "$1"\n')
            ui.chmod(0o755)
            env = {**os.environ, "HOME": str(home)}
            for args in [[], ["open"], ["capture"]]:
                output = subprocess.check_output(
                    [sys.executable, str(ROOT / "bin/nacre-brain"), *args],
                    env=env,
                    text=True,
                )
                self.assertEqual(output, "capture" if args == ["capture"] else "brain")
            env["SIVERTEH_BRAIN"] = str(home / "custom-vault")
            output = subprocess.check_output(
                [sys.executable, str(ROOT / "bin/nacre-brain"), "path"],
                env=env,
                text=True,
            ).strip()
            self.assertEqual(output, env["SIVERTEH_BRAIN"])

    def test_browser_profile_guard_recognizes_old_and_new_names(self):
        from unittest.mock import patch

        spec = importlib.util.spec_from_file_location(
            "brain_browser_guard", ROOT / "brain/control.py"
        )
        control = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(control)
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            proc = home / "proc"
            process = proc / "100"
            process.mkdir(parents=True)
            real_path = Path
            with (
                patch.object(control, "HOME", home),
                patch.object(
                    control,
                    "Path",
                    side_effect=lambda value: (
                        proc if value == "/proc" else real_path(value)
                    ),
                ),
            ):
                for profile in [
                    ".local/share/siverteh-ai/observatory-browser",
                    ".local/share/nacre/brain-browser",
                ]:
                    args = [
                        b"chrome",
                        ("--user-data-dir=" + str(home / profile)).encode(),
                    ]
                    (process / "cmdline").write_bytes(b"\0".join(args))
                    self.assertTrue(control.brain_browser_running())
                    self.assertEqual(control.browser_profile_pids(), {100})
                    (process / "cmdline").write_bytes(
                        b"\0".join([*args, b"--type=renderer"])
                    )
                    self.assertFalse(control.brain_browser_running())

    def test_installed_maintenance_setup_uses_runtime_templates(self):
        import shutil

        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            binaries = home / ".local/bin"
            binaries.mkdir(parents=True)
            for name in ("nacre-brain", "nacre-brain-sync", "nacre-brain-maintain"):
                shutil.copy2(ROOT / "bin" / name, binaries / name)
            templates = home / ".local/share/nacre/brain/templates"
            shutil.copytree(ROOT / "ai/brain", templates)
            env = {**os.environ, "HOME": str(home)}
            env.pop("NACRE_BRAIN", None)
            env.pop("SIVERTEH_BRAIN", None)
            subprocess.run(
                [sys.executable, str(binaries / "nacre-brain-maintain"), "setup"],
                env=env,
                check=True,
                capture_output=True,
            )
            vault = home / "Documents/Nacre-Brain"
            for name in ("AGENTS.md", "CLAUDE.md", "INDEX.md"):
                self.assertEqual(
                    (vault / name).read_bytes(), (templates / name).read_bytes()
                )
            (vault / "AGENTS.md").write_text("Personal instructions")
            subprocess.run(
                [sys.executable, str(binaries / "nacre-brain-maintain"), "setup"],
                env=env,
                check=True,
                capture_output=True,
            )
            self.assertEqual((vault / "AGENTS.md").read_text(), "Personal instructions")
