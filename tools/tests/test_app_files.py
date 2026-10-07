"""Native Files route retains safe fallbacks and explicit application choices."""

import importlib.util
from importlib.machinery import SourceFileLoader
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]


class FilesRouteTests(unittest.TestCase):
    def test_missing_dolphin_falls_back_to_nautilus(self):
        loader = SourceFileLoader("app_route", str(ROOT / "bin/siverteh-os-app"))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        app = importlib.util.module_from_spec(spec)
        loader.exec_module(app)
        with tempfile.TemporaryDirectory() as directory:

            def installed(name):
                return None if name == "dolphin" else "/usr/bin/" + name

            with (
                patch.object(app.Path, "home", return_value=Path(directory)),
                patch.object(app.sys, "argv", ["route", "files", "/tmp/with spaces"]),
                patch.object(app.shutil, "which", side_effect=installed),
                patch.object(app.os, "execvp") as execute,
            ):
                app.main()
                execute.assert_called_once_with(
                    "nautilus", ["nautilus", "--new-window", "/tmp/with spaces"]
                )

    def test_explicit_file_manager_is_preserved(self):
        loader = SourceFileLoader("app_route", str(ROOT / "bin/siverteh-os-app"))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        app = importlib.util.module_from_spec(spec)
        loader.exec_module(app)
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            config = home / ".config/siverteh-shell/apps.json"
            config.parent.mkdir(parents=True)
            config.write_text('{"files":["thunar"]}')
            with (
                patch.object(app.Path, "home", return_value=home),
                patch.object(app.sys, "argv", ["route", "files", "/tmp/with spaces"]),
                patch.object(app.shutil, "which", return_value="/usr/bin/thunar"),
                patch.object(app.os, "execvp") as execute,
            ):
                app.main()
                execute.assert_called_once_with(
                    "thunar", ["thunar", "/tmp/with spaces"]
                )
