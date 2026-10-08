import importlib.util, tempfile, unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "release", Path(__file__).parents[1] / "releases.py"
)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class ReleaseTests(unittest.TestCase):
    def test_failed_release_restores_complete_software_and_preserves_account_state(
        self,
    ):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            repo = home / "repo"
            repo.mkdir()
            source = home / ".local/share/siverteh-ai/siverteh-shell/source"
            source.mkdir(parents=True)
            (source / "shell.qml").write_text("before")
            account = home / ".codex/auth.json"
            account.parent.mkdir()
            account.write_text("fixture never snapshot")
            with (
                patch.object(m, "HOME", home),
                patch.object(m, "STATE", home / "releases"),
                patch.object(m.subprocess, "run"),
            ):
                release, record = m.capture(repo, "new")
                (source / "shell.qml").write_text("broken")
                self.assertFalse(any(".codex" in e["path"] for e in record["entries"]))
                m.restore(release, record, force=True)
                self.assertEqual((source / "shell.qml").read_text(), "before")
                self.assertEqual(account.read_text(), "fixture never snapshot")

    def test_rollback_refuses_later_edits(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            repo = home / "repo"
            repo.mkdir()
            source = home / ".local/bin/siverteh-os-shell"
            source.parent.mkdir(parents=True)
            source.write_text("before")
            with (
                patch.object(m, "HOME", home),
                patch.object(m, "STATE", home / "releases"),
            ):
                release, record = m.capture(repo, "new")
                source.write_text("after")
                for e in record["entries"]:
                    e["after"] = m.fingerprint(Path(e["path"]))
                source.write_text("personal edit")
                with self.assertRaisesRegex(RuntimeError, "Later edit preserved"):
                    m.restore(release, record)
                self.assertEqual(source.read_text(), "personal edit")


class RuntimeRetirementTests(unittest.TestCase):
    def test_retirement_preserves_palette_environment_and_is_repeatable(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            base = home / ".local/share/siverteh-ai"
            native = base / "shell-runtime/usr/bin/quickshell"
            native.parent.mkdir(parents=True)
            native.write_text("old binary")
            palette = base / "shell-runtime/venv/keep.txt"
            palette.parent.mkdir()
            palette.write_text("palette environment")
            thunar = base / "thunar-runtime/usr/bin/thunar"
            thunar.parent.mkdir(parents=True)
            thunar.write_text("old file manager")
            release = home / "release"
            with patch.object(m, "HOME", home):
                retired = m.retire_native_runtimes(release)
                self.assertEqual(len(retired), 2)
                self.assertFalse(native.exists())
                self.assertFalse(thunar.exists())
                self.assertEqual(palette.read_text(), "palette environment")
                self.assertEqual(
                    Path(retired[0]["backup"]).joinpath("bin/quickshell").read_text(),
                    "old binary",
                )
                self.assertEqual(m.retire_native_runtimes(release), [])


class RetentionTests(unittest.TestCase):
    def test_newest_current_previous_and_retired_are_protected(self):
        import json

        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory)
            for i in range(15):
                p = state / f"release-{i:02}"
                p.mkdir()
                (p / "release.json").write_text(
                    json.dumps({"status": "good", "revision": str(i), "previous": "1"})
                )
            (state / "release-00/retired-native").mkdir()
            (state / "current.json").write_text(
                json.dumps({"release": str(state / "release-02")})
            )
            with patch.object(m, "STATE", state):
                removed = m.prune_releases()
            self.assertEqual(
                {Path(p).name for p in removed}, {"release-03", "release-04"}
            )
            self.assertTrue((state / "release-00").exists())
            self.assertTrue((state / "release-01").exists())
            self.assertTrue((state / "release-02").exists())
