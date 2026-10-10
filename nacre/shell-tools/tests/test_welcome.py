"""Welcome preference ownership, login deduplication and single-shell activation."""

import importlib.machinery
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch
from concurrent.futures import ThreadPoolExecutor
import contextlib
import io

ROOT = Path(__file__).parents[3]


def load(name, path):
    loader = importlib.machinery.SourceFileLoader(name, str(path))
    spec = importlib.util.spec_from_loader(name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


welcome = load("welcome_owner", ROOT / "nacre/shell-tools/welcome.py")
launcher = load("welcome_launcher", ROOT / "bin/nacre-welcome")
configure = load("welcome_configure", ROOT / "tools/configure.py")


class WelcomeTests(unittest.TestCase):
    def test_disabled_login_and_manual_reads_do_not_reenable(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            self.assertTrue(welcome.preferences(home)["showAtLogin"])
            self.assertFalse(welcome.paths(home)[0].exists())
            welcome.set_startup(home, False)
            before = welcome.paths(home)[0].read_bytes()
            self.assertFalse(welcome.claim_login(home, "session-1")["show"])
            self.assertFalse(welcome.state(home)["preferences"]["showAtLogin"])
            self.assertEqual(before, welcome.paths(home)[0].read_bytes())
            self.assertEqual(welcome.paths(home)[0].stat().st_mode & 0o777, 0o600)

    def test_claim_once_per_session_and_failed_activation_retry(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            first = welcome.claim_login(home, "one")
            self.assertTrue(first["show"])
            self.assertFalse(welcome.claim_login(home, "one")["show"])
            welcome.release_login(home, "one", "other-claim")
            self.assertFalse(welcome.claim_login(home, "one")["show"])
            welcome.release_login(home, "one", first["claim"])
            self.assertTrue(welcome.claim_login(home, "one")["show"])
            self.assertTrue(welcome.claim_login(home, "two")["show"])
            self.assertFalse(welcome.claim_login(home, "")["show"])

    def test_unknown_fields_preserved_and_bad_configuration_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            path, _ = welcome.paths(home)
            path.parent.mkdir(parents=True)
            path.write_text(json.dumps({"version": 1, "custom": "preserve"}))
            welcome.set_startup(home, False)
            self.assertEqual(welcome.preferences(home)["custom"], "preserve")
            for text in ('{"showAtLogin":"no"}', '{"version":2}', "broken json"):
                path.write_text(text)
                with self.assertRaises(ValueError):
                    welcome.set_startup(home, True)
                self.assertEqual(path.read_text(), text)
            with self.assertRaises(ValueError):
                welcome.set_startup(home, "false")

    def test_warm_activation_does_not_start_or_restart_services(self):
        runner = Mock(return_value=subprocess.CompletedProcess([], 0, "", ""))
        launcher.open_welcome("shortcuts", runner=runner)
        self.assertEqual(runner.call_count, 1)
        self.assertEqual(
            runner.call_args.args[0][-3:], ["welcomeApp", "open", "shortcuts"]
        )

    def test_cold_activation_starts_one_existing_service_with_bounded_retry(self):
        bad = subprocess.CompletedProcess([], 1, "", "")
        good = subprocess.CompletedProcess([], 0, "", "")
        runner = Mock(side_effect=[bad, good, bad, good])
        sleep = Mock()
        launcher.open_welcome(runner=runner, sleep=sleep)
        self.assertEqual(
            runner.call_args_list[1].args[0],
            ["systemctl", "--user", "start", "--no-block", "nacre-shell.service"],
        )
        self.assertEqual(sleep.call_count, 2)
        runner = Mock(return_value=bad)
        with self.assertRaises(RuntimeError):
            launcher.open_welcome(runner=runner, sleep=Mock())
        self.assertEqual(runner.call_count, 2)

    def test_concurrent_login_claims_activate_only_once(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            with ThreadPoolExecutor(max_workers=4) as pool:
                results = list(
                    pool.map(lambda _: welcome.claim_login(home, "same"), range(4))
                )
            self.assertEqual(sum(item["show"] for item in results), 1)

    def test_disabled_login_cli_does_not_start_shell_or_open_window(self):
        with (
            patch("sys.argv", ["nacre-welcome", "--login"]),
            patch.object(launcher, "helper", return_value={"show": False, "claim": ""}),
            patch.object(launcher, "open_welcome") as opener,
        ):
            self.assertEqual(launcher.main(), 0)
            opener.assert_not_called()

    def test_failed_login_cli_releases_its_claim(self):
        with (
            patch("sys.argv", ["nacre-welcome", "--login"]),
            patch.object(
                launcher,
                "helper",
                side_effect=[{"show": True, "claim": "ours"}, {"released": True}],
            ) as helper,
            patch.object(
                launcher, "open_welcome", side_effect=RuntimeError("unavailable")
            ),
            contextlib.redirect_stderr(io.StringIO()),
        ):
            self.assertEqual(launcher.main(), 1)
            self.assertEqual(helper.call_args.args, ("release-login", "ours"))

    def test_deployment_and_login_owner_are_declared(self):
        mapping = configure.files(ROOT)
        self.assertIn(Path(".local/bin/nacre-welcome"), mapping)
        self.assertIn(Path(".local/share/applications/nacre-welcome.desktop"), mapping)
        entry = (ROOT / "nacre/desktop/nacre-welcome.desktop").read_text()
        self.assertIn("Icon=nacre\n", entry)
        self.assertIn("Terminal=false", entry)
        startup = (ROOT / "hypr/conf/autostart.lua").read_text()
        self.assertEqual(startup.count('"--login"'), 1)
        self.assertNotIn("--login", (ROOT / "nacre/shell/shell.qml").read_text())
