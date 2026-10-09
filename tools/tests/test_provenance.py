import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location(
    "provenance", Path(__file__).parents[1] / "provenance.py"
)
provenance = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(provenance)


class ProvenanceTests(unittest.TestCase):
    def test_names_and_change_records_do_not_certify_origin(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "spec.md").write_text("behavior")
            (root / "Nacre.qml").write_text("source")
            registry = {
                "version": 1,
                "change_records": [
                    {
                        "area": "test",
                        "commit": "123",
                        "spec": "spec.md",
                        "paths": ["Nacre.qml"],
                    }
                ],
            }
            result = provenance.inventory(root, registry, ["Nacre.qml"])
            self.assertEqual(result[0]["audit"], "pending")
            self.assertEqual(len(result[0]["recorded_changes"]), 1)

    def test_modified_review_is_stale_and_missing_file_cannot_pass(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "helper.py"
            path.write_bytes(b"original")
            registry = {
                "version": 1,
                "reviews": {
                    "helper.py": {
                        "disposition": "independent",
                        "evidence": ["spec and author review"],
                        "sha256": hashlib.sha256(b"original").hexdigest(),
                    }
                },
            }
            self.assertEqual(
                provenance.inventory(root, registry, ["helper.py"])[0]["audit"],
                "reviewed",
            )
            path.write_bytes(b"changed")
            self.assertEqual(
                provenance.inventory(root, registry, ["helper.py"])[0]["audit"], "stale"
            )
            path.unlink()
            self.assertEqual(
                provenance.inventory(root, registry, ["helper.py"])[0]["audit"], "stale"
            )

    def test_retired_or_unsubstantiated_review_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            with self.assertRaisesRegex(ValueError, "untracked"):
                provenance.inventory(root, {"version": 1, "reviews": {"old": {}}}, [])
            with self.assertRaisesRegex(ValueError, "evidence"):
                provenance.inventory(
                    root,
                    {"version": 1, "reviews": {"new": {"disposition": "independent"}}},
                    ["new"],
                )

    def test_symlink_inventory_hashes_link_not_external_content(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "link").symlink_to("missing-private-target")
            result = provenance.inventory(root, {"version": 1}, ["link"])
            self.assertEqual(
                result[0]["sha256"],
                hashlib.sha256(b"missing-private-target").hexdigest(),
            )

    def test_whole_tree_categories_cover_helpers_assets_and_tests(self):
        samples = {
            "nacre/shell/assets/font.ttf": "shell-asset",
            "nacre/shell-tools/branding.py": "desktop-helper-data",
            "nacre/shell-tools/tests/fixture.png": "test-fixture",
            "hypr/scripts/startup-apps.sh": "desktop-config-helper",
            "nacre/shell/NOTICE": "license-notice",
        }
        for path, expected in samples.items():
            self.assertEqual(provenance.category(path), expected)
