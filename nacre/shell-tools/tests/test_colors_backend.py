"""Real preview/export/favorite/apply behavior in an isolated fake desktop home."""

import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import select
import tempfile
import unittest
from unittest.mock import patch
from PIL import Image

TOOLS = Path(__file__).parents[1]
sys.path.insert(0, str(TOOLS.parent / "shell-cli/src"))
spec = importlib.util.spec_from_file_location("colors_app_backend", TOOLS / "colors.py")
colors = importlib.util.module_from_spec(spec)
spec.loader.exec_module(colors)
from orient.engine import default_palette


class ColorsBackendTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.home = Path(temporary.name)
        changes = patch.multiple(
            colors,
            HOME=self.home,
            CACHE=self.home / ".cache/nacre/colors",
            STORE=self.home / ".config/nacre/colors.json",
            EXPORTS=self.home / "exports",
        )
        changes.start()
        self.addCleanup(changes.stop)
        changes = patch.multiple(
            colors.media,
            HOME=self.home,
            LIBRARY=self.home / "Pictures/Wallpapers",
            CACHE=self.home / ".cache/nacre/wallpaper-media",
            STATE=self.home / ".local/state/nacre/wallpaper",
            PREFS=self.home / ".config/nacre/wallpaper-picker.json",
        )
        changes.start()
        self.addCleanup(changes.stop)
        changes = patch.dict(
            os.environ,
            {
                "HOME": str(self.home),
                "XDG_CACHE_HOME": str(self.home / ".cache"),
                "XDG_CONFIG_HOME": str(self.home / ".config"),
                "XDG_STATE_HOME": str(self.home / ".local/state"),
            },
        )
        changes.start()
        self.addCleanup(changes.stop)
        self.image = self.home / "scene.png"
        image = Image.new("RGB", (64, 40), "#172b45")
        image.paste("#db788f", (24, 12, 40, 28))
        image.save(self.image)

    def preview(self, **extra):
        return colors.stage({"image": str(self.image), **extra})

    def test_preview_is_read_only_and_staged_record_detects_changed_image(self):
        data = self.preview(personality="pop")
        self.assertFalse(colors.STORE.exists())
        self.assertFalse(colors.media.PREFS.exists())
        self.assertFalse((self.home / ".local/state/nacre/scheme.json").exists())
        self.assertEqual(len(data["comparisons"]), 8)
        self.assertTrue(data["palette"]["accessibility"]["textPasses"])
        self.assertEqual(colors.record(data["id"])["request"]["personality"], "pop")
        Image.new("RGB", (64, 40), "#ee8844").save(self.image)
        with self.assertRaisesRegex(ValueError, "changed"):
            colors.record(data["id"])

    @unittest.skipUnless(shutil.which("rsvg-convert"), "SVG renderer unavailable")
    def test_favorite_both_modes_apply_history_and_new_home(self):
        data = self.preview(personality="harmony")
        result = colors.favorite(data["id"], "Evening")
        self.assertEqual(result["saved"], "Evening")
        saved = colors.stored()["favorites"][0]
        self.assertEqual(set(saved["modes"]), {"dark", "light"})
        result = colors.apply(data["id"], live=False)
        self.assertTrue(result["applied"])
        published = json.loads(
            (self.home / ".local/state/nacre/presentation.json").read_text()
        )
        self.assertEqual(published["palettePersonality"], "harmony")
        self.assertEqual(len(colors.stored()["history"]), 1)
        self.assertEqual(colors.stored()["lastApplied"], data["id"])
        item = self.preview(favoriteId=saved["id"], mode="light")
        self.assertEqual(item["palette"]["colours"], saved["modes"]["light"])
        colors.apply(item["id"], live=False)
        self.assertEqual(
            colors.media.settings()["palettePreset"], "favorite:" + saved["id"]
        )
        colors.catalog()  # A saved preset must satisfy the existing catalogue schema.

    def test_export_card_and_custom_template_stay_in_output_folder(self):
        data = self.preview()
        result = colors.export(data["id"])
        directory = Path(result["directory"])
        self.assertTrue((directory / "palette.json").is_file())
        self.assertTrue((directory / "firefox/manifest.json").is_file())
        result = colors.card(data["id"])
        self.assertTrue(Path(result["card"]).is_file())
        self.assertFalse((self.home / ".config/kitty").exists())
        self.assertFalse((self.home / ".config/gtk-4.0").exists())

    def test_picked_point_and_pinned_roles_preserve_readability(self):
        data = self.preview(
            pick={"x": 0.5, "y": 0.5},
            overrides={"secondary": "47a87f"},
            brightness=0.08,
            saturation=1.3,
        )
        self.assertRegex(data["request"]["accent"], r"^[0-9a-f]{6}$")
        self.assertTrue(data["palette"]["accessibility"]["textPasses"])
        with self.assertRaises(ValueError):
            self.preview(hour=27)
        with self.assertRaises(ValueError):
            colors.record("../other")

    def test_worker_responds_without_waiting_for_stdin_eof(self):
        process = subprocess.Popen(
            [sys.executable, str(TOOLS / "colors.py"), "preview"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env={**os.environ, "PYTHONPATH": str(TOOLS.parent / "shell-cli/src")},
        )

        def cleanup():
            if process.poll() is None:
                process.kill()
            process.wait()
            for stream in (process.stdin, process.stdout, process.stderr):
                stream.close()

        self.addCleanup(cleanup)
        process.stdin.write(json.dumps({"image": str(self.image)}) + "\n")
        process.stdin.flush()
        self.assertTrue(
            select.select([process.stdout], [], [], 10)[0],
            "worker must reply before stdin closes",
        )
        response = process.stdout.readline()
        self.assertEqual(process.wait(timeout=10), 0, process.stderr.read())
        self.assertIn("id", json.loads(response))
        process.stdin.close()
        process.stdout.close()
        process.stderr.close()
