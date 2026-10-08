import importlib.util
from pathlib import Path
import subprocess
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "updates", Path(__file__).resolve().parents[1] / "updates.py"
)
updates = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updates)


class UpdateTests(unittest.TestCase):
    def check(self, helper_result):
        results = [
            subprocess.CompletedProcess(["checkupdates"], 2, "", ""),
            helper_result,
        ]
        with (
            patch.object(updates.shutil, "which", side_effect=lambda name: name),
            patch.object(updates.subprocess, "run", side_effect=results),
        ):
            return updates.count_updates()

    def test_empty_aur_result_refreshes_to_zero(self):
        result = self.check(subprocess.CompletedProcess(["paru", "-Qua"], 1, "", ""))
        self.assertEqual(result["count"], 0)
        self.assertEqual(result["text"], "0")

    def test_aur_update_is_counted(self):
        result = self.check(
            subprocess.CompletedProcess(["paru", "-Qua"], 0, "chrome 1 -> 2\n", "")
        )
        self.assertEqual(result["count"], 1)

    def test_failed_aur_query_does_not_report_zero(self):
        with self.assertRaises(RuntimeError):
            self.check(
                subprocess.CompletedProcess(
                    ["paru", "-Qua"], 1, "", "error: network failure"
                )
            )


if __name__ == "__main__":
    unittest.main()
