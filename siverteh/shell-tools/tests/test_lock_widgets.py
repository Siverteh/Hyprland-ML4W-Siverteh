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

    def test_media_controls_scale_with_the_shared_panel_on_4k(self):
        colors = json.loads((ROOT / "reference-style.json").read_text())["colours"]
        for width, height in ((1920, 1080), (2880, 1800), (3840, 2160), (7680, 4320)):
            output = config.render(
                colors,
                "/tmp/wall.png",
                {},
                Path("/tmp/helper"),
                [dict(name="test", width=width, height=height)],
            )
            scale = min(width / 2048, height / 1152)
            # Each control must be centered on its prepared rounded button.
            for x, action in ((165, "previous"), (238, "toggle"), (311, "next")):
                pattern = f"position = {round((x - 720) * scale)}, {round((405 - 687) * scale)}"
                self.assertIn(pattern, output)
            self.assertEqual(output.count("input-field {"), 1)
            self.assertNotIn("unlock-session", output)

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

    def test_weather_prepares_feels_like_and_daily_range(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            settings = home / ".config/siverteh-shell/desktop.json"
            settings.parent.mkdir(parents=True)
            settings.write_text(json.dumps(dict(weatherLocation="Test city")))
            forecast = dict(
                current_condition=[
                    dict(
                        weatherCode="113",
                        weatherDesc=[dict(value="Sunny")],
                        temp_C="28",
                        FeelsLikeC="32",
                    )
                ],
                weather=[dict(maxtempC="34", mintempC="27")],
            )
            with (
                patch.object(weather, "HOME", home),
                patch.object(weather, "CACHE", home / "weather.json"),
                patch.object(weather, "fetch_json", return_value=forecast),
            ):
                data = weather.refresh()
            self.assertEqual(data["feelsLike"], 32)
            self.assertEqual((data["high"], data["low"]), (34, 27))
            self.assertFalse(data["stale"])
            self.assertEqual(data["description"], "Sunny")

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
