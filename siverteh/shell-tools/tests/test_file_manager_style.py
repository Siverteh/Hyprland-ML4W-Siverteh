import importlib.util
from pathlib import Path
import tempfile
import unittest

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
            self.assertTrue((target / "64x64/places/inode-directory.svg").is_symlink())
            self.assertTrue((target / "64x64/places/folder-documents.svg").is_symlink())
            stamp = (target / "index.theme").stat().st_mtime_ns
            self.assertEqual(icons.theme(home, "ff1010", "dark"), chosen)
            self.assertEqual((target / "index.theme").stat().st_mtime_ns, stamp)
            self.assertIn(
                "Inherits=Papirus-Dark,Papirus,Adwaita,hicolor",
                (target / "index.theme").read_text(),
            )

    def test_kde_roles_preserve_user_settings_and_selection_contrast(self):
        import configparser
        import json

        kde = load("kde-palette")
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            config = home / ".config/kdeglobals"
            config.parent.mkdir(parents=True)
            config.write_text(
                "[General]\nTerminalApplication=kitty\n[UserSection]\nSetting=preserve\n"
            )
            presets = json.loads((ROOT / "palette-presets.json").read_text())
            colors = next(p for p in presets if p["id"] == "ocean")["modes"]["dark"]
            kde.publish(home, colors, "ExampleIcons")
            parsed = configparser.ConfigParser(interpolation=None)
            parsed.read(config)
            self.assertEqual(parsed["General"]["TerminalApplication"], "kitty")
            self.assertEqual(parsed["UserSection"]["Setting"], "preserve")
            self.assertEqual(
                parsed["Colors:View"]["BackgroundNormal"], "#" + colors["surface"]
            )
            self.assertEqual(
                parsed["Colors:Selection"]["ForegroundInactive"],
                "#" + colors["onPrimary"],
            )
            self.assertEqual(
                parsed["Colors:Selection"]["BackgroundAlternate"],
                "#" + colors["primary"],
            )
            self.assertTrue(
                (home / ".local/share/color-schemes/Siverteh.colors").exists()
            )
