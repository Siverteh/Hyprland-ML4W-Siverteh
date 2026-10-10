"""Independent engine/public-format invariants and reproducible gallery."""

import importlib.util
import json
import os
from pathlib import Path
import sys
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).parents[1]
sys.path.insert(0, str(ROOT.parent / "shell-cli/src"))
from PIL import Image
from orient.engine import from_image
from orient.colour import lch, hue_distance
from orient.accessibility import simulate, difference
from orient.export import export, render
from orient.extract import sample_color
from orient.palette import PERSONALITIES


class Orient3Tests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        env = patch.dict(
            os.environ,
            {
                "HOME": str(self.home),
                "XDG_CACHE_HOME": str(self.home / ".cache"),
                "XDG_STATE_HOME": str(self.home / ".state"),
                "XDG_CONFIG_HOME": str(self.home / ".config"),
            },
        )
        env.start()
        self.addCleanup(env.stop)

    def scene(self, base, accent, name="scene.png"):
        p = self.home / name
        image = Image.new("RGB", (128, 80), "#" + base)
        image.paste("#" + accent, (48, 26, 80, 54))
        image.save(p)
        return p

    def test_natural_body_comes_from_shadow_not_accent(self):
        p = self.scene("28160f", "2870db")
        data = from_image(p)
        self.assertLess(
            hue_distance(lch(data["colours"]["surface"])[2], lch("28160f")[2]), 15
        )
        self.assertLess(
            hue_distance(
                lch(from_image(p, accent="df2020")["colours"]["surface"])[2],
                lch("28160f")[2],
            ),
            15,
        )
        q = self.scene("07152b", "ed566e", "navy.png")
        self.assertLess(
            hue_distance(lch(from_image(q)["colours"]["surface"])[2], lch("07152b")[2]),
            15,
        )

    def test_light_body_from_bright_population_and_every_role_has_provenance(self):
        p = self.scene("eee3ce", "276ba0")
        data = from_image(p, "light")
        self.assertGreater(lch(data["colours"]["surface"])[0], 0.94)
        self.assertLess(
            hue_distance(lch(data["colours"]["surface"])[2], lch("eee3ce")[2]), 20
        )
        self.assertEqual(set(data["colours"]), set(data["provenance"]))
        self.assertTrue(data["accessibility"]["textPasses"])
        self.assertEqual(data["formatVersion"], 1)

    def test_personalities_and_pearl_are_readable_and_distinct(self):
        p = self.scene("202c4a", "ec75ba")
        palettes = {name: from_image(p, personality=name) for name in PERSONALITIES}
        self.assertEqual(
            len({p["colours"]["primary"] for p in palettes.values()}) >= 4, True
        )
        for value in palettes.values():
            self.assertTrue(value["accessibility"]["textPasses"])
        q = self.scene("493017", "40996a", "other.png")
        self.assertEqual(
            palettes["pearl"]["colours"], from_image(q, personality="pearl")["colours"]
        )
        self.assertNotEqual(
            from_image(p, personality="tide", hour=8)["colours"]["surface"],
            from_image(p, personality="tide", hour=20)["colours"]["surface"],
        )

    def test_salience_coverage_locations_and_small_crop_stability(self):
        p = self.scene("253452", "e19858")
        data = from_image(p)
        candidate = next(
            c
            for c in data["source"]["candidates"]
            if hue_distance(lch(c["hex"])[2], lch("e19858")[2]) < 10
        )
        self.assertGreater(candidate["salience"], 1)
        self.assertAlmostEqual(candidate["coverage"], 32 * 28 / (128 * 80), delta=0.03)
        self.assertAlmostEqual(candidate["location"]["x"], 0.5, delta=0.03)
        self.assertTrue(candidate["regions"]["cells"])
        image = Image.open(p)
        q = self.home / "crop.png"
        image.crop((4, 2, 124, 78)).save(q)
        self.assertLess(
            difference(data["source"]["selected"], from_image(q)["source"]["selected"]),
            0.05,
        )

    def test_animated_frames_and_semantic_terminal_hues(self):
        fixture = ROOT / "tests/orient-gallery/images/moving-lantern.gif"
        data = from_image(fixture)
        self.assertEqual(data["source"]["sample"]["frames"], 4)
        for mode in ("dark", "light"):
            c = from_image(fixture, mode)["colours"]
            self.assertLess(hue_distance(lch(c["red"])[2], lch("df303e")[2]), 8)
            self.assertLess(hue_distance(lch(c["green"])[2], lch("289563")[2]), 8)

    @unittest.skipUnless(
        shutil.which("ffmpeg") and shutil.which("ffprobe"), "Video decoder unavailable"
    )
    def test_short_video_samples_stay_inside_last_decodable_frame(self):
        target = self.home / "short.mp4"
        subprocess.run(
            [
                "ffmpeg",
                "-v",
                "error",
                "-i",
                str(ROOT / "tests/orient-gallery/images/moving-lantern.gif"),
                "-pix_fmt",
                "yuv420p",
                "-y",
                str(target),
            ],
            check=True,
            capture_output=True,
            timeout=10,
        )
        data = from_image(target)
        self.assertEqual(data["source"]["sample"]["frames"], 4)
        self.assertTrue(data["accessibility"]["textPasses"])

    def test_export_json_toml_templates_no_overwrite_and_no_publication(self):
        import tomllib

        p = self.scene("192b42", "ac6abd")
        data = from_image(p)
        target = self.home / "export"
        files = export(data, target)
        self.assertGreaterEqual(len(files), 12)
        json.loads((target / "vscode-theme.json").read_text())
        json.loads((target / "firefox/manifest.json").read_text())
        tomllib.loads((target / "alacritty.toml").read_text())
        with self.assertRaises(ValueError):
            export(data, target)
        with self.assertRaises(ValueError):
            render("{{not_a_role}}", data)
        self.assertFalse((self.home / ".config/nacre").exists())
        self.assertFalse((self.home / ".state/nacre").exists())

    def test_installed_runtime_symlink_can_export_builtins(self):
        import orient.export as exporter

        alias = self.home / "active-runtime"
        alias.symlink_to(Path(exporter.__file__).parent, target_is_directory=True)
        data = from_image(self.scene("203450", "aa679b"))
        with patch.object(exporter, "__file__", str(alias / "export.py")):
            paths = exporter.export(data, self.home / "export-symlink")
        self.assertEqual(len(paths), 13)

    def test_vision_simulation_neutrals_and_safe_adjustments(self):
        for vision in ("protanopia", "deuteranopia", "tritanopia"):
            value = simulate("808080", vision)
            self.assertLess(
                max(int(value[i : i + 2], 16) for i in (0, 2, 4))
                - min(int(value[i : i + 2], 16) for i in (0, 2, 4)),
                2,
            )
        p = self.scene("253452", "e19858")
        a = from_image(
            p, overrides={"secondary": "109950"}, brightness=0.05, saturation=1.2
        )
        self.assertTrue(a["accessibility"]["textPasses"])
        with self.assertRaises(ValueError):
            from_image(p, saturation=2)
        with self.assertRaises(ValueError):
            sample_color(p, 1.2, 0.5)

    def test_gallery_matches_reviewed_palette_snapshots(self):
        path = ROOT / "tests/orient-gallery/snapshot.py"
        spec = importlib.util.spec_from_file_location("gallery_snapshot", path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        self.assertEqual(
            module.snapshot(), json.loads(path.with_name("palettes.json").read_text())
        )
