import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]


def load(name):
    spec = importlib.util.spec_from_file_location(name, ROOT / (name + ".py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class FileManagerTests(unittest.TestCase):
    def test_folder_palette_overlay_is_small_and_reused(self):
        icons = load("file-icons")
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            base = home / ".local/share/icons"
            for name in ["Papirus", "Papirus-Dark"]:
                (base / name).mkdir(parents=True)
                (base / name / "index.theme").write_text("[Icon Theme]\n")
            source = base / "Papirus/64x64/places"
            source.mkdir(parents=True)
            (source / "folder-red.svg").write_text("<svg/>")
            (source / "folder-red-documents.svg").write_text("<svg/>")
            chosen = icons.theme(home, "ff0000", "dark")
            target = base / chosen
            self.assertTrue((target / "64x64/places/folder.svg").is_symlink())
            self.assertTrue((target / "64x64/places/folder-documents.svg").is_symlink())
            stamp = (target / "index.theme").stat().st_mtime_ns
            self.assertEqual(icons.theme(home, "ff1010", "dark"), chosen)
            self.assertEqual((target / "index.theme").stat().st_mtime_ns, stamp)
            self.assertIn(
                "Inherits=Papirus-Dark,Papirus,Adwaita,hicolor",
                (target / "index.theme").read_text(),
            )

    def test_compact_default_is_applied_once_then_user_choice_is_preserved(self):
        style = load("file-manager-style")
        with tempfile.TemporaryDirectory() as folder:
            marker = Path(folder) / "style.json"
            response = type("Result", (), {"returncode": 0, "stdout": "'medium'\n"})()
            with (
                patch.object(style, "MARKER", marker),
                patch.object(style.subprocess, "run", return_value=response) as run,
            ):
                style.main()
                self.assertEqual(run.call_count, 2)
                self.assertIn("medium", marker.read_text())
                style.main()
                self.assertEqual(run.call_count, 2)
