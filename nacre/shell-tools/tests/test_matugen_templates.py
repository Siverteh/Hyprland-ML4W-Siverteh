"""Color-template compatibility, exact mode context and read-only CLI/export."""

import json
import os
from pathlib import Path
import sys
import tempfile
import subprocess
import unittest

SRC = Path(__file__).parents[2] / "shell-cli/src"
sys.path.insert(0, str(SRC))
from orient.template_engine import render_values
from orient.engine import default_palette, from_image
from orient.export import render, export
from PIL import Image


class MatugenTemplateTests(unittest.TestCase):
    def test_standard_roles_formats_whitespace_and_legacy_tokens(self):
        values = {
            "primary": "224466",
            "onPrimaryContainer": "ffffff",
            "overtone": "335577",
            "mode": "dark",
        }
        self.assertEqual(
            render_values(
                "#{{primary}} {{ colors.on_primary_container.default.hex }} {{colors.source_color.default.hex_stripped}}",
                values,
            ),
            "#224466 #ffffff 335577",
        )
        self.assertEqual(
            render_values(
                "{{ colors.primary.default.rgb }} / {{ colors.primary.default.rgba }}",
                values,
            ),
            "rgb(34, 68, 102) / rgba(34, 68, 102, 1.0)",
        )
        self.assertEqual(
            render_values(
                "{{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }},{{ colors.primary.default.alpha }}",
                values,
            ),
            "34,68,102,255",
        )
        self.assertEqual(
            render_values(
                "{{colors.primary.default.hsl}} {{colors.primary.default.hsla}}", values
            ),
            "hsl(210, 50%, 26.667%) hsla(210, 50%, 26.667%, 1.0)",
        )
        self.assertEqual(render_values("{{ colors.primary.hex }}", values), "#224466")
        self.assertEqual(
            render_values(
                "{{mode}} {{is_dark_mode}} {{custom.font}} {{image}}",
                values,
                image="/tmp/photo.png",
                custom={"font": "Noto Sans"},
            ),
            "dark true Noto Sans /tmp/photo.png",
        )

    def test_explicit_modes_are_never_silently_substituted(self):
        values = {"primary": "224466", "mode": "dark"}
        text = "{{colors.primary.dark.hex}} {{colors.primary.light.hex}}"
        with self.assertRaisesRegex(ValueError, "companion"):
            render_values(text, values)
        self.assertEqual(
            render_values(text, values, schemes={"light": {"primary": "aabbcc"}}),
            "#224466 #aabbcc",
        )

    def test_escaped_tokens_json_braces_and_unsupported_logic(self):
        values = {"primary": "224466", "mode": "dark"}
        result = render_values(
            '{"nested":{"accent":"{{ colors.primary.default.hex }}"}}', values
        )
        self.assertEqual(json.loads(result)["nested"]["accent"], "#224466")
        self.assertEqual(
            render_values(r"\{{ colors.primary.default.hex }}", values),
            "{{ colors.primary.default.hex }}",
        )
        for text in (
            "<* include 'secret' *>",
            "{{colors.primary.default.hex | invert}}",
            "{{ colors.nope.default.hex }}",
            "{{palettes.primary._99.hex}}",
            "{{ colors.primary.default.xyz }}",
            "{{ {{primary}} }}",
            "{{broken",
        ):
            with self.subTest(text=text), self.assertRaises(ValueError):
                render_values(text, values)

    def test_all_builtin_templates_and_imported_matugen_css_export(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            template = root / "templates"
            template.mkdir()
            (template / "theme.css.in").write_text(
                ":root{--fg:{{ colors.on_surface.default.hex }};--bg:{{colors.surface.default.hex}};}"
            )
            palette = default_palette("light")
            files = export(palette, root / "export", template)
            self.assertEqual(len(files), 1)
            self.assertNotIn("{{", Path(files[0]).read_text())
            with self.assertRaises(ValueError):
                export(palette, root / "export", template)
            export(palette, root / "builtins")
            self.assertEqual(len(list((root / "builtins").rglob("*.*"))), 13)

    def test_opposite_mode_can_be_generated_from_unchanged_source(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            image = root / "scene.png"
            Image.new("RGB", (64, 40), "#ad4867").save(image)
            palette = from_image(image, cache_dir=root / "cache")
            text = "{{ colors.primary.dark.hex }} {{ colors.primary.light.hex }}"
            result = render(text, palette)
            expected = from_image(image, "light", cache_dir=root / "cache")
            self.assertEqual(
                result,
                "#"
                + palette["colours"]["primary"]
                + " #"
                + expected["colours"]["primary"],
            )
            Image.new("RGB", (64, 40), "#338899").save(image)
            with self.assertRaisesRegex(ValueError, "changed"):
                render(text, palette)

    def test_standalone_render_accepts_plain_file_and_companion_without_publication(
        self,
    ):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            p = root / "palette.json"
            p.write_text(json.dumps(default_palette("dark")))
            other = root / "light.json"
            other.write_text(json.dumps(default_palette("light")))
            template = root / "theme.css"
            template.write_text("p{color:{{colors.primary.light.hex}}}")
            env = {
                **os.environ,
                "HOME": str(root),
                "XDG_CACHE_HOME": str(root / "cache"),
                "PYTHONPATH": str(SRC),
            }
            result = subprocess.run(
                [
                    sys.executable,
                    "-m",
                    "orient",
                    "render",
                    str(p),
                    str(template),
                    "--companion",
                    str(other),
                ],
                env=env,
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn("{{", result.stdout)
            self.assertTrue(result.stdout.startswith("p{color:#"))
            self.assertFalse((root / ".config/nacre").exists())
            self.assertFalse((root / ".local/state/nacre").exists())
