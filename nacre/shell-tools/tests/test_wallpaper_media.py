import importlib.util, json, os, tempfile, unittest
from pathlib import Path
from unittest.mock import patch
from PIL import Image

spec = importlib.util.spec_from_file_location(
    "wallpaper_media", Path(__file__).resolve().parents[1] / "wallpaper-media.py"
)
media = importlib.util.module_from_spec(spec)
spec.loader.exec_module(media)


class WallpaperMediaTests(unittest.TestCase):
    def test_static_and_animated_gif_have_distinct_identity_and_posters(self):
        with (
            tempfile.TemporaryDirectory() as folder,
            patch.object(media, "CACHE", Path(folder) / "cache"),
        ):
            static = Path(folder) / "Still.png"
            Image.new("RGB", (32, 24), "red").save(static)
            animated = Path(folder) / "Motion.gif"
            frames = [Image.new("RGB", (32, 24), c) for c in ("red", "blue")]
            frames[0].save(
                animated, save_all=True, append_images=frames[1:], duration=100, loop=0
            )
            self.assertFalse(media.describe(static)["dynamic"])
            item = media.describe(animated)
            self.assertTrue(item["dynamic"])
            self.assertTrue(item["animated"])
            self.assertNotEqual(item["path"], item["poster"])
            self.assertTrue(Path(item["poster"]).is_file())

    def test_previews_are_small_private_reused_and_invalidated_after_change(self):
        with (
            tempfile.TemporaryDirectory() as folder,
            patch.object(media, "CACHE", Path(folder) / "cache"),
        ):
            source = Path(folder) / "Large.png"
            Image.new("RGB", (3840, 2160), "red").save(source)
            first = media.describe(source)
            stamp = Path(first["thumbnail"]).stat().st_mtime_ns
            again = media.describe(source)
            self.assertEqual(first["thumbnail"], again["thumbnail"])
            self.assertEqual(stamp, Path(again["thumbnail"]).stat().st_mtime_ns)
            for name, limit in [("thumbnail", 640), ("preview", 1600)]:
                path = Path(first[name])
                self.assertEqual(path.stat().st_mode & 0o777, 0o600)
                with Image.open(path) as image:
                    self.assertLessEqual(image.width, limit)
            Image.new("RGB", (3840, 2160), "blue").save(source)
            changed = media.describe(source)
            self.assertNotEqual(first["thumbnail"], changed["thumbnail"])

    def test_preferences_are_validated_private_and_preserve_other_fields(self):
        with (
            tempfile.TemporaryDirectory() as folder,
            patch.object(media, "PREFS", Path(folder) / "picker.json"),
        ):
            media.preference({"layout": "hexagons"})
            media.preference({"kind": "dynamic"})
            self.assertEqual(media.settings()["layout"], "hexagons")
            self.assertEqual(os.stat(media.PREFS).st_mode & 0o777, 0o600)
            with self.assertRaises(ValueError):
                media.preference({"layout": "command-line"})

    def test_rotation_and_palette_preferences_validate_without_clobbering_picker(self):
        with (
            tempfile.TemporaryDirectory() as folder,
            patch.object(media, "PREFS", Path(folder) / "picker.json"),
        ):
            media.preference(
                {
                    "layout": "hexagons",
                    "rotationEnabled": True,
                    "rotationMinutes": 30,
                    "rotationKind": "dynamic",
                    "rotationShuffle": False,
                    "palettePreset": "ocean",
                }
            )
            media.preference({"rotationMinutes": 60})
            saved = media.settings()
            self.assertEqual(saved["layout"], "hexagons")
            self.assertEqual(saved["palettePreset"], "ocean")
            self.assertEqual(saved["rotationMinutes"], 60)
            for value in [True, 0, 4, 1441, 2.5, "30"]:
                with self.assertRaises(ValueError):
                    media.preference({"rotationMinutes": value})
            for value in [
                {"palettePreset": "arbitrary-file"},
                {"paletteMode": "auto"},
                {"rotationKind": "brain"},
                {"rotationEnabled": "yes"},
            ]:
                with self.assertRaises(ValueError):
                    media.preference(value)
            self.assertEqual(media.settings(), saved)

    def test_theme_failure_restores_preferences(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            poster = base / "poster.png"
            Image.new("RGB", (20, 20), "red").save(poster)
            state = base / "state"
            state.mkdir()
            (state / "media.json").write_text(json.dumps({"poster": str(poster)}))
            with (
                patch.object(media, "STATE", state),
                patch.object(media, "PREFS", base / "picker.json"),
                patch.object(
                    media.subprocess, "run", side_effect=RuntimeError("test failure")
                ),
            ):
                with self.assertRaises(RuntimeError):
                    media.theme({"palettePreset": "ocean"})
                self.assertEqual(media.settings()["palettePreset"], "wallpaper")
                self.assertTrue(poster.exists())

    def test_rotation_anchor_survives_preferences_and_legacy_reload(self):
        with (
            tempfile.TemporaryDirectory() as folder,
            patch.object(media, "PREFS", Path(folder) / "picker.json"),
        ):
            with patch.object(media.time, "time", return_value=1000):
                media.preference({"rotationEnabled": True, "rotationMinutes": 30})
            self.assertEqual(media.settings()["rotationAnchorMs"], 1000000)
            with patch.object(media.time, "time", return_value=2000):
                media.preference({"layout": "hexagons", "palettePreset": "ocean"})
                self.assertEqual(media.settings()["rotationAnchorMs"], 1000000)
                media.preference({"rotationMinutes": 60})
                self.assertEqual(media.settings()["rotationAnchorMs"], 2000000)
            media.PREFS.write_text(
                json.dumps({"rotationEnabled": True, "rotationMinutes": 30})
            )
            os.utime(media.PREFS, (800, 800))
            self.assertEqual(media.settings()["rotationAnchorMs"], 800000)
            self.assertEqual(media.settings()["rotationAnchorMs"], 800000)

    def test_media_migration_preserves_success_time_without_rewriting(self):
        with (
            tempfile.TemporaryDirectory() as folder,
            patch.object(media, "STATE", Path(folder)),
        ):
            path = media.STATE / "media.json"
            path.write_text(json.dumps({"path": "old.mp4", "poster": "poster.png"}))
            os.utime(path, (500, 500))
            self.assertEqual(media.media_state()["appliedAtMs"], 500000)
            self.assertNotIn("appliedAtMs", json.loads(path.read_text()))

    def test_import_preserves_original_and_does_not_overwrite_names(self):
        with (
            tempfile.TemporaryDirectory() as folder,
            patch.object(media, "LIBRARY", Path(folder) / "walls"),
        ):
            source = Path(folder) / "Example.png"
            Image.new("RGB", (32, 24), "blue").save(source)
            first = media.import_files([str(source)])
            second = media.import_files([str(source)])
            self.assertNotEqual(first, second)
            self.assertTrue(source.exists())
            self.assertTrue(Path(first[0]).exists())

    def test_only_successful_selection_advances_persisted_photo_time(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            with (
                patch.object(media, "HOME", home),
                patch.object(media, "STATE", home / "state"),
                patch.object(media, "CACHE", home / "cache"),
            ):
                source = home / "image.png"
                Image.new("RGB", (30, 30), "red").save(source)
                with (
                    patch.object(media.subprocess, "run"),
                    patch.object(media.time, "time", return_value=1234),
                ):
                    item = media.select(source)
                self.assertEqual(item["appliedAtMs"], 1234000)
                with (
                    patch.object(
                        media.subprocess, "run", side_effect=RuntimeError("failed")
                    ),
                    patch.object(media.time, "time", return_value=9999),
                ):
                    with self.assertRaises(RuntimeError):
                        media.select(source)
                self.assertEqual(
                    json.loads((media.STATE / "media.json").read_text())["appliedAtMs"],
                    1234000,
                )

    def test_failed_palette_commit_does_not_publish_media_state(self):
        with (
            tempfile.TemporaryDirectory() as folder,
            patch.object(media, "STATE", Path(folder) / "state"),
            patch.object(media, "CACHE", Path(folder) / "cache"),
            patch.object(media.subprocess, "run", side_effect=RuntimeError),
        ):
            source = Path(folder) / "image.png"
            Image.new("RGB", (32, 24), "red").save(source)
            with self.assertRaises(RuntimeError):
                media.select(source)
            self.assertFalse((media.STATE / "media.json").exists())
