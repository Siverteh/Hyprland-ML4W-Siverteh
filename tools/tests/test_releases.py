import importlib.util, json, tempfile, unittest
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
