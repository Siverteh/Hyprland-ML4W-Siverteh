import importlib.util, unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "startup", Path(__file__).resolve().parents[1] / "startup-apps.py"
)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class StartupTests(unittest.TestCase):
    def test_empty_session_plans_only_requested_six_apps(self):
        plan = m.plan([])
        self.assertEqual(
            [(p[0], p[1]) for p in plan],
            [
                ("Browser", 1),
                ("Nacre AI", 2),
                ("Discord", 3),
                ("Spotify", 4),
                ("Mail", 5),
                ("Brain", 6),
            ],
        )
        self.assertTrue(all(not p[3] for p in plan))
        self.assertNotIn("chatgpt", str(plan).lower())

    def test_existing_brain_app_is_not_mistaken_for_main_browser(self):
        plan = m.plan([{"class": "chrome-127.0.0.1__-Default", "title": "Nacre Brain"}])
        self.assertFalse(plan[0][3])
        self.assertTrue(plan[5][3])

    def test_existing_apps_are_not_launched_twice(self):
        clients = [
            {"class": name, "title": ""}
            for name in [
                "Google-chrome",
                "siverteh-ai-dashboard",
                "discord",
                "Spotify",
                "org.gnome.Evolution",
                "siverteh-brain",
            ]
        ]
        self.assertTrue(all(p[3] for p in m.plan(clients)))
