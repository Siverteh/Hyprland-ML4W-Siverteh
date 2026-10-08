"""Checked-in preset colors must remain reproducible with the pinned engine."""

import importlib.util
import importlib.metadata
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class GeneratedPresetTests(unittest.TestCase):
    @unittest.skipUnless(
        importlib.util.find_spec("materialyoucolor")
        and importlib.util.find_spec("siverteh_shell"),
        "Pinned palette engine unavailable",
    )
    def test_regenerated_presets_match_the_committed_artifact(self):
        self.assertEqual(importlib.metadata.version("materialyoucolor"), "3.0.4")
        spec = importlib.util.spec_from_file_location(
            "palette_generator", ROOT / "generate-palettes.py"
        )
        generator = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(generator)
        self.assertEqual(
            generator.build(), json.loads((ROOT / "palette-presets.json").read_text())
        )
