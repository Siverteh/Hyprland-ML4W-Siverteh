"""Verify the launcher geometry without invoking logout or power actions."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[2] / 'siverteh/scripts/wlogout.sh'

class WlogoutGeometry(unittest.TestCase):
    def run_launcher(self, monitors, failed=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'hyprctl').write_text('#!/bin/sh\n[ "$*" = "-j monitors" ] || exit 2\ncat "$MONITORS"\nexit "${MONITOR_STATUS:-0}"\n')
            (root / 'wlogout').write_text('#!/bin/sh\nprintf "%s\\n" "$@" > "$ARGUMENTS"\n')
            for name in ('hyprctl', 'wlogout'):
                (root / name).chmod(0o755)
            monitor_path = root / 'monitors.json'
            monitor_path.write_text(monitors if isinstance(monitors, str) else json.dumps(monitors))
            arguments = root / 'arguments'
            env = {**os.environ, 'PATH': f'{root}:{os.environ["PATH"]}',
                   'MONITORS': str(monitor_path), 'ARGUMENTS': str(arguments),
                   'MONITOR_STATUS': '1' if failed else '0'}
            result = subprocess.run(['bash', str(SCRIPT)], env=env, text=True, capture_output=True)
            return result, arguments.read_text().splitlines() if arguments.exists() else None

    def test_fractional_and_integer_scales(self):
        for height, scale, expected in ((1080, 1, 259), (1800, 1.5, 288), (1440, 1.25, 276), (2160, 2, 259)):
            with self.subTest(height=height, scale=scale):
                result, args = self.run_launcher([{'height': height, 'scale': scale, 'focused': True}])
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(args, ['-b','3','-c','10','-r','10','-T',str(expected),'-B',str(expected)])
                self.assertLess(expected * 2, height / scale)

    def test_focused_monitor_wins(self):
        result, args = self.run_launcher([{'height': 1080, 'scale': 1, 'focused': False}, {'height': 1800, 'scale': 1.5, 'focused': True}])
        self.assertEqual(result.returncode, 0)
        self.assertEqual(args[-1], '288')

    def test_first_monitor_when_none_focused(self):
        result, args = self.run_launcher([{'height': 1080, 'scale': 1, 'focused': False}])
        self.assertEqual(result.returncode, 0)
        self.assertEqual(args[-1], '259')

    def test_invalid_geometry_never_launches(self):
        for value in ([], [{'height': 1800, 'scale': 0}], [{'height': -1, 'scale': 1}], [{'height': 1800}], 'invalid-json'):
            with self.subTest(value=value):
                result, args = self.run_launcher(value)
                self.assertNotEqual(result.returncode, 0)
                self.assertIsNone(args)

    def test_hyprctl_failure_never_launches(self):
        result, args = self.run_launcher([{'height': 1800, 'scale': 1.5, 'focused': True}], failed=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIsNone(args)

if __name__ == '__main__':
    unittest.main()
