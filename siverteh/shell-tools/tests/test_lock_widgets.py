import importlib.util, json, tempfile, unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, ROOT / file)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


info = module("lockinfo", "lock-info.py")
config = module("lockconfig", "lock-config.py")
devices = module("devices", "device-actions.py")
weather = module("weather", "weather.py")


class LockAndDeviceTests(unittest.TestCase):
    def test_notification_privacy_is_enforced_again_after_cache_read(self):
        data = {
            "count": 1,
            "notifications": [
                {"app": "Mail", "summary": "Private title", "body": "Private body"}
            ],
        }
        text = info.label("notifications", data, {})
        self.assertNotIn("Private", text)
        self.assertIn("Mail", text)
        self.assertIn(
            "Private title",
            info.label("notifications", data, {"lockNotificationContents": True}),
        )
        self.assertEqual(
            info.label("notifications", data, {"lockNotifications": False}), ""
        )

    def test_untrusted_metadata_is_escaped_for_pango(self):
        text = info.label(
            "media",
            {
                "media": {
                    "title": '<span foreground="red">Oops</span>',
                    "artist": "A & B",
                }
            },
            {},
        )
        self.assertNotIn("<span", text)
        self.assertIn("&lt;span", text)
        self.assertIn("A &amp; B", text)

    def test_render_respects_preferences_and_has_no_unlock_action(self):
        colors = json.loads((ROOT / "reference-style.json").read_text())["colours"]
        output = config.render(
            colors,
            "/tmp/wallpaper.png",
            {"lockMedia": False, "lockWeather": False},
            Path("/tmp/lock-info.py"),
        )
        self.assertNotIn("skip_next", output)
        self.assertNotIn("weather\n", output)
        self.assertIn("Notifications", info.label("notifications", {}, {}))
        self.assertIn("input-field", output)
        self.assertNotIn("{{", output)
        self.assertNotIn("unlock-session", output)
        with self.assertRaises(ValueError):
            config.render(colors, "/tmp/evil\nlabel {}", {}, Path("/tmp/helper.py"))

    def test_long_labels_fit_the_card_and_are_bounded(self):
        import html

        for font in (14, 16):
            text = html.unescape(info.plain("WWWW" * 200, lines=2, font=font))
            self.assertLessEqual(len(text.splitlines()), 2)
            self.assertTrue(text.endswith("…"))
            self.assertTrue(
                all(
                    info.text_font(font).getlength(line) <= 288
                    for line in text.splitlines()
                )
            )

    def test_media_controls_have_fixed_card_relative_spacing_on_4k(self):
        colors = json.loads((ROOT / "reference-style.json").read_text())["colours"]
        import re

        for width in (1920, 2880, 3840, 7680):
            output = config.widgets("media", colors, Path("/tmp/helper"), "test", width)
            positions = [
                int(v) for v in re.findall(r"position = (-?\d+), -280", output)
            ]
            self.assertEqual(
                sorted(positions),
                [
                    round(-0.32 * width) - 64,
                    round(-0.32 * width),
                    round(-0.32 * width) + 64,
                ],
            )

    def test_control_center_uses_native_pixel_coordinates_and_rotation(self):
        self.assertEqual(
            config.output_width({"width": 2880, "height": 1800, "scale": 1.5}), 2880
        )
        self.assertEqual(
            config.output_width(
                {"width": 2880, "height": 1800, "scale": 1.5, "transform": 1}
            ),
            1800,
        )

    def test_device_names_are_arguments_and_actions_are_bounded(self):
        self.assertEqual(
            devices.command("wifi-connect", "$(anything); space")[-1],
            "$(anything); space",
        )
        self.assertIn("--ask", devices.command("wifi-connect", "WiFi"))
        with self.assertRaises(ValueError):
            devices.command("bluetooth-connect", "AA:BB:CC;anything")
        with self.assertRaises(ValueError):
            devices.command("shell", "anything")

    def test_weather_failure_preserves_cache_timestamp(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            cache = home / "weather.json"
            cache.write_text(
                json.dumps(
                    {"checked": 123, "description": "Overcast", "temperature": 10}
                )
            )
            with (
                patch.object(weather, "HOME", home),
                patch.object(weather, "CACHE", cache),
                patch.object(weather, "fetch_json", side_effect=TimeoutError),
            ):
                data = weather.refresh()
            self.assertEqual(data["checked"], 123)
            self.assertTrue(data["stale"])
            self.assertEqual(data["temperature"], 10)
