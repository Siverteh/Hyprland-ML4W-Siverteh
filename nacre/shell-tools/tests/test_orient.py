"""Independent engine invariants, image behavior and CLI publication boundaries."""

import colorsys
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

try:
    from PIL import Image, ImageCms
except ImportError:
    Image = None

SOURCE = Path(__file__).resolve().parents[2] / "shell-cli/src"
sys.path.insert(0, str(SOURCE))
if Image:
    from nacre_shell.colour import color, contrast, hue_distance, lch
    from nacre_shell.engine import from_image
    from nacre_shell.extract import analyze
    from nacre_shell.palette import generate


@unittest.skipUnless(Image, "Pillow unavailable")
class OrientTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.environment = patch.dict(
            os.environ,
            {
                "HOME": str(self.home),
                "XDG_CONFIG_HOME": str(self.home / ".config"),
                "XDG_STATE_HOME": str(self.home / ".local/state"),
                "XDG_CACHE_HOME": str(self.home / ".cache"),
            },
        )
        self.environment.start()
        self.addCleanup(self.environment.stop)

    def image(self, seed, name="image.png"):
        path = self.home / name
        Image.new("RGB", (128, 80), "#" + seed).save(path)
        return path

    def cli(self, *args):
        return subprocess.run(
            [sys.executable, "-m", "nacre_shell", *args],
            env={**os.environ, "PYTHONPATH": str(SOURCE)},
            capture_output=True,
            text=True,
        )

    def test_color_round_trip_and_fixed_hue_gamut(self):
        for seed in (
            "d01818",
            "ff3030",
            "ff791f",
            "4275ff",
            "11d96c",
            "ffffff",
            "000000",
        ):
            result = color(*lch(seed))
            self.assertTrue(
                all(
                    abs(int(seed[i : i + 2], 16) - int(result[i : i + 2], 16)) <= 1
                    for i in (0, 2, 4)
                )
            )
        mapped = color(0.6, 0.7, 30)
        self.assertLess(hue_distance(lch(mapped)[2], 30), 1)

    def test_saturated_red_stays_red_instead_of_pastel(self):
        source = "d01818"
        for mode in ("light", "dark"):
            data = from_image(self.image(source), mode)
            c = data["colours"]
            self.assertEqual(c["overtone"], source)
            self.assertLess(hue_distance(lch(c["primary"])[2], lch(source)[2]), 2)
            saturation = colorsys.rgb_to_hsv(
                *(int(c["primary"][i : i + 2], 16) / 255 for i in (0, 2, 4))
            )[1]
            self.assertGreater(saturation, 0.65)
            self.assertGreaterEqual(
                contrast(c["primary"], c["surfaceContainerHighest"]), 4.5
            )

    def test_red_orange_magenta_blue_green_are_distinct(self):
        for seed in ("d01818", "fa6a10", "cc22aa", "255fdf", "109f50"):
            analysis = analyze(self.image(seed))
            self.assertLess(hue_distance(lch(seed)[2], lch(analysis["seed"])[2]), 2)

    def test_coverage_beats_tiny_neon_detail(self):
        path = self.image("bb2020")
        image = Image.open(path)
        image.paste("#00ff00", (0, 0, 8, 8))
        image.save(path)
        self.assertLess(
            hue_distance(lch(analyze(path)["seed"])[2], lch("bb2020")[2]), 3
        )

    def test_neutral_background_does_not_hide_meaningful_subject(self):
        path = self.image("181818")
        image = Image.open(path)
        image.paste("#b02020", (40, 20, 88, 60))
        image.save(path)
        analysis = analyze(path)
        self.assertFalse(analysis["neutral"])
        self.assertLess(hue_distance(lch(analysis["seed"])[2], lch("b02020")[2]), 3)

    def test_candidate_override_keeps_identity_between_modes(self):
        path = self.image("bb2020")
        for mode in ("light", "dark"):
            data = from_image(path, mode, accent="2255aa")
            self.assertEqual(data["source"]["selected"], "2255aa")
            self.assertEqual(data["colours"]["overtone"], "2255aa")

    def test_transparent_rgb_does_not_invent_color(self):
        path = self.home / "alpha.png"
        image = Image.new("RGBA", (128, 80), (0, 255, 0, 0))
        image.paste((180, 20, 20, 255), (40, 20, 88, 60))
        image.save(path)
        self.assertLess(
            hue_distance(lch(analyze(path)["seed"])[2], lch("b41414")[2]), 3
        )
        Image.new("RGBA", (64, 64), (255, 0, 0, 0)).save(path)
        with self.assertRaises(ValueError):
            analyze(path)

    def test_grayscale_has_no_fabricated_candidate_hues(self):
        for seed in ("eeeeee", "101010", "888888"):
            data = analyze(self.image(seed))
            self.assertTrue(data["neutral"])
            self.assertEqual(len(data["candidates"]), 1)
            self.assertEqual(data["candidates"][0]["chroma"], 0)

    def test_profile_and_orientation_normalization(self):
        path = self.home / "profile.png"
        profile = ImageCms.ImageCmsProfile(ImageCms.createProfile("sRGB")).tobytes()
        image = Image.new("RGB", (80, 120), "#d01818")
        exif = image.getexif()
        exif[274] = 6
        image.save(path, icc_profile=profile, exif=exif)
        self.assertLess(
            hue_distance(lch(analyze(path)["seed"])[2], lch("d01818")[2]), 3
        )
        image.save(path, icc_profile=b"bad profile")
        with self.assertRaises(ValueError):
            analyze(path)

    def test_unsafe_or_invalid_inputs_are_errors(self):
        path = self.home / "bad.png"
        path.write_bytes(b"not an image")
        with self.assertRaises(OSError):
            analyze(path)
        image = self.image("ff3030")
        with patch("nacre_shell.extract.MAX_PIXELS", 10):
            with self.assertRaises(ValueError):
                analyze(image)

    def test_cache_determinism_and_invalidation(self):
        path = self.image("d01818")
        first = from_image(path)
        with patch(
            "nacre_shell.engine.analyze",
            side_effect=AssertionError("warm cache must not extract"),
        ):
            self.assertEqual(from_image(path), first)
        self.image("2255aa")
        second = from_image(path)
        self.assertNotEqual(first["source"]["digest"], second["source"]["digest"])
        self.assertNotEqual(first["source"]["selected"], second["source"]["selected"])
        self.assertNotEqual(from_image(path, "light")["colours"], second["colours"])

    def test_corrupt_cache_recomputed(self):
        path = self.image("d01818")
        expected = from_image(path)
        cache = next((self.home / ".cache/nacre/orient").glob("*.json"))
        for broken in ([], None, {"engine": "orient-2.0.0", "colours": None}):
            cache.write_text(json.dumps(broken))
            self.assertEqual(from_image(path), expected)
        broken = dict(expected, source=[])
        cache.write_text(json.dumps(broken))
        self.assertEqual(from_image(path), expected)

    def test_all_required_roles_and_contrast_across_hues(self):
        roles = json.loads(Path(__file__).with_name("orient-roles.json").read_text())
        for hue in range(0, 360, 20):
            seed = color(0.6, 0.24, hue)
            for mode in ("light", "dark"):
                c = generate(seed, mode)
                self.assertTrue(set(roles) <= c.keys())
                for fg in (
                    "primary",
                    "secondary",
                    "tertiary",
                    "onSurface",
                    "onSurfaceVariant",
                ):
                    for bg in (
                        "surface",
                        "surfaceContainerHighest",
                        "surfaceBright" if mode == "dark" else "surfaceDim",
                    ):
                        self.assertGreaterEqual(contrast(c[fg], c[bg]), 4.5)
                for role in ("Primary", "Secondary", "Tertiary", "Error", "Success"):
                    self.assertGreaterEqual(
                        contrast(c["on" + role], c[role.lower()]), 4.5
                    )
                    self.assertGreaterEqual(
                        contrast(
                            c["on" + role + "Container"], c[role.lower() + "Container"]
                        ),
                        4.5,
                    )
                self.assertGreaterEqual(
                    contrast(c["outline"], c["surfaceContainerHighest"]), 3
                )

    def test_print_and_query_never_publish(self):
        path = self.image("d01818")
        result = self.cli("wallpaper", "-p", str(path))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)["name"], "dynamic")
        self.assertFalse((self.home / ".local/state/nacre").exists())
        self.assertEqual(self.cli("scheme", "get", "--mode").stdout.strip(), "dark")
        self.assertFalse((self.home / ".local/state/nacre").exists())

    def test_invalid_selection_leaves_committed_state(self):
        result = self.cli("wallpaper", "-f", str(self.image("d01818")))
        self.assertEqual(result.returncode, 0, result.stderr)
        state = self.home / ".local/state/nacre/scheme.json"
        before = state.read_bytes()
        self.assertNotEqual(
            self.cli("wallpaper", "-f", str(self.home / "missing.png")).returncode, 0
        )
        self.assertEqual(state.read_bytes(), before)

    def test_saved_mode_and_persistent_accent(self):
        path = self.image("d01818")
        config = self.home / ".config/nacre"
        config.mkdir(parents=True)
        (config / "wallpaper-picker.json").write_text('{"paletteMode":"dark"}')
        self.assertEqual(self.cli("wallpaper", "-f", str(path)).returncode, 0)
        self.assertEqual(self.cli("scheme", "set", "--accent", "2255aa").returncode, 0)
        data = json.loads(self.cli("wallpaper", "-p", str(path)).stdout)
        self.assertEqual(data["source"]["selected"], "2255aa")
        self.assertEqual(self.cli("scheme", "set", "-m", "light").returncode, 0)
        self.assertEqual(self.cli("scheme", "get", "-m").stdout.strip(), "light")
        self.assertEqual(self.cli("scheme", "set", "--auto-accent").returncode, 0)
        self.assertEqual(
            json.loads(self.cli("wallpaper", "-p", str(path)).stdout)["source"][
                "selected"
            ],
            "d01818",
        )

    def test_named_default_and_legacy_variants(self):
        for variant in (
            "tonalspot",
            "vibrant",
            "expressive",
            "fidelity",
            "fruitsalad",
            "monochrome",
            "neutral",
            "rainbow",
            "content",
        ):
            result = self.cli(
                "scheme", "set", "-n", "default", "-v", variant, "-m", "dark"
            )
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.cli("scheme", "set", "-f", "unsupported").returncode, 2)

    def test_read_only_print_skips_custom_hook(self):
        config = self.home / ".config/nacre"
        config.mkdir(parents=True)
        (config / "cli.json").write_text(
            json.dumps({"wallpaper": {"postHook": 'touch "$HOME/hook-called"'}})
        )
        path = self.image("d01818")
        self.assertEqual(self.cli("wallpaper", "-p", str(path)).returncode, 0)
        self.assertFalse((self.home / "hook-called").exists())
        self.assertEqual(self.cli("wallpaper", "-f", str(path)).returncode, 0)
        self.assertTrue((self.home / "hook-called").exists())


class OrientBridgeTests(unittest.TestCase):
    def test_queries_skip_publisher_but_changes_publish_under_shared_lock(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            runtime = home / ".local/share/nacre/palette-runtime/venv/bin"
            runtime.mkdir(parents=True)
            cli = runtime / "nacre_shell"
            cli.write_text(
                '#!/bin/sh\nif [ "$2" = set ]; then printf "%s" "${NACRE_PALETTE_LOCKED:-}" > "$HOME/locked"; fi\nprintf "ok\\n"\n'
            )
            cli.chmod(0o755)
            tools = home / ".local/share/nacre/shell/tools"
            tools.mkdir(parents=True)
            (tools / "classic-state.py").write_text(
                'from pathlib import Path\n(Path.home()/"published").write_text("yes")\n'
            )
            bridge = Path(__file__).parents[1] / "cli-bridge.sh"
            for args in (
                ("scheme", "get", "-m"),
                ("wallpaper", "-p", "ignored"),
                ("wallpaper", "--print=ignored"),
            ):
                result = subprocess.run(
                    ["bash", str(bridge), *args],
                    env={**os.environ, "HOME": str(home)},
                    capture_output=True,
                    text=True,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse((home / "published").exists())
                self.assertFalse(
                    (home / ".local/state/nacre/palette-commit.lock").exists()
                )
            result = subprocess.run(
                ["bash", str(bridge), "scheme", "set", "-m", "dark"],
                env={**os.environ, "HOME": str(home)},
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((home / "published").exists())
            self.assertEqual((home / "locked").read_text(), "1")


class OrientPublicCommandTests(unittest.TestCase):
    def test_palette_commands_use_bridge_while_plain_wallpaper_opens_picker(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            binary = home / ".local/share/nacre/shell/bin"
            binary.mkdir(parents=True)
            for name, label in (("nacre_shell", "bridge"), ("qs", "picker")):
                path = binary / name
                path.write_text('#!/bin/sh\nprintf "%s\\n" "' + label + '" "$@"\n')
                path.chmod(0o755)
            control = Path(__file__).parents[1] / "control.sh"
            for args, label in (
                (("scheme", "set", "-m", "dark"), "bridge"),
                (("wallpaper", "-p", "image"), "bridge"),
                (("wallpaper",), "picker"),
            ):
                result = subprocess.run(
                    ["bash", str(control), *args],
                    env={**os.environ, "HOME": str(home)},
                    capture_output=True,
                    text=True,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout.splitlines()[0], label)
