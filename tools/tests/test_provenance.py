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
    def test_git_failure_keeps_the_actual_diagnostic(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(
                RuntimeError, "Cannot inventory Git index.*not a git repository"
            ):
                provenance.tracked_paths(Path(directory))

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


class CompletionTests(unittest.TestCase):
    def test_incomplete_or_inherited_sources_cannot_complete(self):
        records = [
            {"path": str(provenance.REGISTRY), "audit": "pending", "review": None},
            {"path": "view.qml", "audit": "pending", "review": None},
        ]
        with self.assertRaisesRegex(ValueError, "Unfinished.*view.qml"):
            provenance.completion_metadata(Path("."), records, "a" * 40)
        records[1].update(audit="reviewed", review={"disposition": "inherited"})
        with self.assertRaisesRegex(ValueError, "Unfinished.*view.qml"):
            provenance.completion_metadata(Path("."), records, "a" * 40)
        records[1].update(audit="stale", review={"disposition": "independent"})
        with self.assertRaisesRegex(ValueError, "Unfinished.*view.qml"):
            provenance.completion_metadata(Path("."), records, "a" * 40)

    def test_circular_or_unpinned_metadata_cannot_complete(self):
        records = [
            {"path": str(provenance.REGISTRY), "audit": "pending", "review": None}
        ]
        with self.assertRaisesRegex(ValueError, "immutable"):
            provenance.completion_metadata(Path("."), records, "main")
        records[0]["review"] = {"disposition": "non-implementation"}
        with self.assertRaisesRegex(ValueError, "circular"):
            provenance.completion_metadata(Path("."), records, "a" * 40)

    def test_real_git_anchor_rejects_later_metadata_edits(self):
        import json
        import os
        import subprocess
        from unittest.mock import patch

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            metadata = root / provenance.REGISTRY
            metadata.parent.mkdir(parents=True)
            metadata.write_text(json.dumps({"version": 1, "reviews": {}}))
            env = {
                "PATH": os.environ["PATH"],
                "HOME": str(root),
                "GIT_CONFIG_NOSYSTEM": "1",
                "GIT_CONFIG_GLOBAL": "/dev/null",
                "GIT_AUTHOR_NAME": "Nacre fixture",
                "GIT_AUTHOR_EMAIL": "fixture@example.invalid",
                "GIT_COMMITTER_NAME": "Nacre fixture",
                "GIT_COMMITTER_EMAIL": "fixture@example.invalid",
            }
            with patch.dict(os.environ, env, clear=True):
                for command in (
                    ["git", "init", "--quiet"],
                    ["git", "add", str(provenance.REGISTRY)],
                    ["git", "commit", "--quiet", "-m", "Metadata fixture"],
                ):
                    subprocess.run(command, cwd=root, check=True, capture_output=True)
                revision = subprocess.check_output(
                    ["git", "rev-parse", "HEAD"], cwd=root, text=True
                ).strip()
                records = [
                    {
                        "path": str(provenance.REGISTRY),
                        "audit": "pending",
                        "review": None,
                    }
                ]
                result = provenance.completion_metadata(root, records, revision)
                import contextlib
                import io
                import sys

                output = io.StringIO()
                with (
                    patch.object(provenance, "ROOT", root),
                    patch.object(
                        sys,
                        "argv",
                        [
                            "provenance",
                            "--complete",
                            "--metadata-revision",
                            revision,
                            "--json",
                        ],
                    ),
                    contextlib.redirect_stdout(output),
                ):
                    provenance.main()
                self.assertEqual(
                    json.loads(output.getvalue())["metadata_audit"], result
                )
                self.assertEqual(result["revision"], revision)
                self.assertEqual(
                    result["sha256"], hashlib.sha256(metadata.read_bytes()).hexdigest()
                )
                metadata.write_text('{"version": 1, "reviews": {}, "changed": true}')
                with self.assertRaisesRegex(ValueError, "differs"):
                    provenance.completion_metadata(root, records, revision)
