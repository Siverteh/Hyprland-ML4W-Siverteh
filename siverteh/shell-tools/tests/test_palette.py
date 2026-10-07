from unittest.mock import patch
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location(
    "palette", Path(__file__).resolve().parents[1] / "classic-state.py"
)
palette = importlib.util.module_from_spec(spec)
spec.loader.exec_module(palette)


class PaletteCommitTest(unittest.TestCase):
    def test_wallpaper_commit_updates_consumers_and_preserves_terminal(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            state = home / ".local/state/siverteh_shell"
            state.mkdir(parents=True)
            colors = json.loads(
                (
                    Path(__file__).resolve().parents[1] / "reference-style.json"
                ).read_text()
            )["colours"]
            colors["primary"] = "#123456"
            (state / "scheme.json").write_text(
                json.dumps({"mode": "light", "colours": colors})
            )
            terminal = home / ".config/kitty/kitty.conf"
            terminal.parent.mkdir(parents=True)
            terminal.write_text("foreground #fedcba\n")
            palette.apply_palette(home, "/tmp/example-wallpaper.png", live=False)
            self.assertIn(
                "rgba(123456ff)",
                (home / ".config/siverteh-shell/palette.lua").read_text(),
            )
            self.assertIn(
                "@define-color accent_color #123456;",
                (home / ".config/gtk-3.0/gtk.css").read_text(),
            )
            self.assertIn(
                "#ff123456", (home / ".config/siverteh-shell/qt.conf").read_text()
            )
            self.assertIn(
                "accent: #123456;",
                (home / ".config/siverteh-shell/rofi.rasi").read_text(),
            )
            self.assertEqual(
                (home / ".config/siverteh-shell/colors/primary").read_text(), "#123456"
            )
            self.assertIn(
                "active_border_color #123456",
                (home / ".config/siverteh-shell/kitty-colors.conf").read_text(),
            )
            self.assertIn(
                "color4 #"
                + palette.readable(colors["inversePrimary"], colors["inverseSurface"])
                + "\n",
                (home / ".config/siverteh-shell/kitty-colors.conf").read_text(),
            )
            self.assertIn(
                "color14 #"
                + palette.readable(colors["secondary"], colors["inverseSurface"])
                + "\n",
                (home / ".config/siverteh-shell/kitty-colors.conf").read_text(),
            )
            self.assertIn(
                "outer_color = rgba(123456ff)",
                (home / ".config/hypr/hyprlock.conf").read_text(),
            )
            self.assertIn("primary 123456", (state / "scheme/current.txt").read_text())
            self.assertEqual(
                (state / "wallpaper/last.txt").read_text(), "/tmp/example-wallpaper.png"
            )
            self.assertEqual(terminal.read_text(), "foreground #fedcba\n")
            term = (home / ".config/siverteh-shell/kitty-colors.conf").read_text()
            self.assertIn("background #" + colors["inverseSurface"], term)
            self.assertIn("foreground #" + colors["inverseOnSurface"], term)

    def test_fixed_palette_survives_different_wallpaper_colors_and_modes(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            state = home / ".local/state/siverteh_shell"
            state.mkdir(parents=True)
            prefs = home / ".config/siverteh-shell/wallpaper-picker.json"
            prefs.parent.mkdir(parents=True)
            prefs.write_text(
                json.dumps({"palettePreset": "ocean", "paletteMode": "dark"})
            )
            presets = json.loads(
                Path(palette.__file__).with_name("palette-presets.json").read_text()
            )
            expected = next(p for p in presets if p["id"] == "ocean")["modes"]["dark"]
            for primary, mode in [("ff0000", "light"), ("00ff00", "dark")]:
                colors = json.loads(
                    Path(palette.__file__).with_name("reference-style.json").read_text()
                )["colours"]
                colors["primary"] = primary
                (state / "scheme.json").write_text(
                    json.dumps({"name": "dynamic", "mode": mode, "colours": colors})
                )
                palette.apply_palette(home, "/tmp/" + primary + ".png", live=False)
                presentation = json.loads((state / "presentation.json").read_text())
                self.assertEqual(presentation["colours"], expected)
                self.assertEqual(presentation["mode"], "dark")
                self.assertEqual(presentation["poster"], "/tmp/" + primary + ".png")
            prefs.write_text(json.dumps({"palettePreset": "wallpaper"}))
            colors["primary"] = "ffaabb"
            (state / "scheme.json").write_text(
                json.dumps({"mode": "light", "colours": colors})
            )
            palette.apply_palette(home, "/tmp/follow.png", live=False)
            self.assertEqual(
                json.loads((state / "presentation.json").read_text())["colours"][
                    "primary"
                ],
                "ffaabb",
            )

    def test_presets_have_all_roles_and_readable_foreground_pairs(self):
        presets = json.loads(
            Path(palette.__file__).with_name("palette-presets.json").read_text()
        )
        roles = json.loads(
            Path(palette.__file__).with_name("reference-style.json").read_text()
        )["colours"]
        for preset in presets:
            for colors in preset["modes"].values():
                self.assertTrue(roles.keys() <= colors.keys())
                for foreground, background in [
                    ("onSurface", "surface"),
                    ("onPrimary", "primary"),
                    ("onSecondary", "secondary"),
                ]:
                    a, b = sorted(
                        [
                            palette.luminance(colors[foreground]),
                            palette.luminance(colors[background]),
                        ]
                    )
                    self.assertGreaterEqual((b + 0.05) / (a + 0.05), 4.5)

    def test_prepared_commit_uses_shared_publisher_and_preserves_cli_identity(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            state = home / ".local/state/siverteh_shell"
            state.mkdir(parents=True)
            colors = json.loads(
                (
                    Path(__file__).resolve().parents[1] / "reference-style.json"
                ).read_text()
            )["colours"]
            data = {
                "name": "dynamic",
                "flavour": "default",
                "variant": "tonalspot",
                "mode": "dark",
                "colours": colors,
            }
            (state / "scheme.json").write_text(json.dumps(data))
            image = home / "wall.png"
            image.write_bytes(b"fixture")
            thumbnail = home / ".cache/siverteh_shell/wallpapers/key/thumbnail.jpg"
            thumbnail.parent.mkdir(parents=True)
            thumbnail.write_bytes(b"fixture")
            with patch.object(palette, "apply_palette") as publisher:
                self.assertTrue(
                    palette.commit_prepared(home, image, data, thumbnail, live=False)
                )
                publisher.assert_called_once_with(home, str(image), live=False)
            self.assertEqual((state / "wallpaper/current").resolve(), image)
            self.assertEqual((state / "wallpaper/thumbnail.jpg").resolve(), thumbnail)
            before = (state / "scheme.json").read_bytes()
            bad = dict(data, colours=dict(colors, primary="bad"))
            self.assertFalse(
                palette.commit_prepared(home, image, bad, thumbnail, live=False)
            )
            self.assertEqual((state / "scheme.json").read_bytes(), before)
            config = home / ".config/siverteh_shell/cli.json"
            config.parent.mkdir(parents=True)
            config.write_text(json.dumps({"wallpaper": {"postHook": "custom hook"}}))
            self.assertFalse(
                palette.commit_prepared(home, image, data, thumbnail, live=False)
            )

    def test_dim_ansi_text_remains_readable_on_light_and_dark_backgrounds(self):
        for background in ("fbf9f8", "141318"):
            for original in ("dfe3e3", "ffffff", "000000", "008f68", "424848"):
                result = palette.readable(original, background)
                a, b = palette.luminance(result), palette.luminance(background)
                self.assertGreaterEqual((max(a, b) + 0.05) / (min(a, b) + 0.05), 4.5)

    def test_invalid_palette_does_not_replace_committed_state(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            state = home / ".local/state/siverteh_shell"
            (state / "scheme").mkdir(parents=True)
            current = state / "scheme/current.txt"
            current.write_text("previous palette")
            (state / "scheme.json").write_text(
                json.dumps({"mode": "light", "colours": {"primary": "not a hex color"}})
            )
            with self.assertRaises(ValueError):
                palette.apply_palette(home, live=False)
            self.assertEqual(current.read_text(), "previous palette")
            self.assertFalse((home / ".config/siverteh-shell/palette.lua").exists())


if __name__ == "__main__":
    unittest.main()
