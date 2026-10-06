import importlib.util, tempfile, unittest, json
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "timezone_tools", Path(__file__).resolve().parents[1] / "timezone.py"
)
tz = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tz)


class TravelTimezoneTests(unittest.TestCase):
    def test_timezone_validation_rejects_path_and_shell_injection(self):
        self.assertEqual(tz.valid_zone("America/Chicago"), "America/Chicago")
        for value in (
            "../../etc/passwd",
            "America/Chicago;bad",
            "/etc/localtime",
            "Not/A_Real_Zone",
            "America/Chicago\n",
        ):
            with self.assertRaises((ValueError, KeyError)):
                tz.valid_zone(value)

    def test_failed_lookup_keeps_current_zone_and_last_success(self):
        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory)
            config = state / "config.json"
            config.write_text('{"automatic":true}')
            tz.atomic(
                state / "status.json", {"checked": "old", "detected": "America/Chicago"}
            )
            with (
                patch.object(tz, "STATE", state),
                patch.object(tz, "CONFIG", config),
                patch.object(tz, "detect", side_effect=TimeoutError),
                patch.object(tz, "run") as run,
            ):
                tz.update(force=True)
            run.assert_not_called()
            data = json.loads((state / "status.json").read_text())
            self.assertEqual(data["checked"], "old")
            self.assertIn("kept", data["error"])

    def test_disabled_automatic_mode_never_queries_location(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / "config.json"
            config.write_text('{"automatic":false}')
            with (
                patch.object(tz, "CONFIG", config),
                patch.object(tz, "detect") as detect,
            ):
                tz.update(force=True)
            detect.assert_not_called()
