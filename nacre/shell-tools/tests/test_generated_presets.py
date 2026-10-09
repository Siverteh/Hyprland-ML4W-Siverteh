"""Checked-in preset colors must remain reproducible with the pinned engine."""

import importlib.util
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class GeneratedPresetTests(unittest.TestCase):
    @unittest.skipUnless(
        importlib.util.find_spec("PIL") and importlib.util.find_spec("nacre_shell"),
        "Pinned palette engine unavailable",
    )
    def test_regenerated_presets_match_the_committed_artifact(self):
        from nacre_shell import ENGINE_ID

        self.assertTrue(ENGINE_ID.startswith("orient-"))
        spec = importlib.util.spec_from_file_location(
            "palette_generator", ROOT / "generate-palettes.py"
        )
        generator = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(generator)
        self.assertEqual(
            generator.build(), json.loads((ROOT / "palette-presets.json").read_text())
        )
