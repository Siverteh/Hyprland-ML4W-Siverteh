"""Atomic environment cutover retains old bytes and recovers failed promotion."""

import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "orient_provision", Path(__file__).parents[1] / "provision.py"
)
provision = importlib.util.module_from_spec(spec)
spec.loader.exec_module(provision)


class OrientProvisionTests(unittest.TestCase):
    def test_replaces_link_without_modifying_old_environment(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            old, candidate = base / "old", base / "new"
            old.mkdir()
            candidate.mkdir()
            (old / "keep").write_text("old")
            runtime = base / "runtime"
            runtime.symlink_to(old)
            provision.activate_runtime(candidate, runtime, base)
            self.assertEqual(runtime.resolve(), candidate)
            self.assertEqual((old / "keep").read_text(), "old")

    def test_failed_link_promotion_restores_real_runtime(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            runtime, candidate = base / "runtime", base / "new"
            runtime.mkdir()
            candidate.mkdir()
            (runtime / "keep").write_text("old")
            with patch.object(
                provision.os,
                "replace",
                side_effect=OSError("fixture promotion failure"),
            ):
                with self.assertRaises(OSError):
                    provision.activate_runtime(candidate, runtime, base)
            self.assertFalse(runtime.is_symlink())
            self.assertEqual((runtime / "keep").read_text(), "old")
            self.assertFalse((base / ".palette-runtime.next").exists())
