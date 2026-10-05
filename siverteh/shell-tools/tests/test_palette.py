import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('palette', Path(__file__).resolve().parents[1] / 'classic-state.py')
palette = importlib.util.module_from_spec(spec)
spec.loader.exec_module(palette)

class PaletteCommitTest(unittest.TestCase):
    def test_wallpaper_commit_updates_consumers_and_preserves_terminal(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            state = home / '.local/state/siverteh_shell'
            state.mkdir(parents=True)
            colors = json.loads((Path(__file__).resolve().parents[1]/'reference-style.json').read_text())['colours']
            colors['primary'] = '#123456'
            (state / 'scheme.json').write_text(json.dumps({'mode':'light','colours':colors}))
            terminal = home / '.config/kitty/kitty.conf'
            terminal.parent.mkdir(parents=True)
            terminal.write_text('foreground #fedcba\n')
            palette.apply_palette(home, '/tmp/example-wallpaper.png', live=False)
            self.assertIn('rgba(123456ff)', (home / '.config/siverteh-shell/palette.lua').read_text())
            self.assertIn('@define-color accent_color #123456;', (home/'.config/gtk-3.0/gtk.css').read_text())
            self.assertIn('#ff123456', (home/'.config/siverteh-shell/qt.conf').read_text())
            self.assertIn('accent: #123456;', (home / '.config/siverteh-shell/rofi.rasi').read_text())
            self.assertEqual((home/'.config/siverteh-shell/colors/primary').read_text(), '#123456')
            self.assertIn('active_border_color #123456', (home/'.config/siverteh-shell/kitty-colors.conf').read_text())
            self.assertIn('color4 #'+palette.readable(colors['inversePrimary'],colors['inverseSurface'])+'\n',(home/'.config/siverteh-shell/kitty-colors.conf').read_text())
            self.assertIn('color14 #'+palette.readable(colors['secondary'],colors['inverseSurface'])+'\n',(home/'.config/siverteh-shell/kitty-colors.conf').read_text())
            self.assertIn('outer_color = rgba(123456ff)', (home/'.config/hypr/hyprlock.conf').read_text())
            self.assertIn('primary 123456', (state / 'scheme/current.txt').read_text())
            self.assertEqual((state / 'wallpaper/last.txt').read_text(), '/tmp/example-wallpaper.png')
            self.assertEqual(terminal.read_text(), 'foreground #fedcba\n')
            term=(home/'.config/siverteh-shell/kitty-colors.conf').read_text()
            self.assertIn('background #'+colors['inverseSurface'],term)
            self.assertIn('foreground #'+colors['inverseOnSurface'],term)

    def test_dim_ansi_text_remains_readable_on_light_and_dark_backgrounds(self):
        for background in ('fbf9f8','141318'):
            for original in ('dfe3e3','ffffff','000000','008f68','424848'):
                result=palette.readable(original,background)
                a,b=palette.luminance(result),palette.luminance(background)
                self.assertGreaterEqual((max(a,b)+0.05)/(min(a,b)+0.05),4.5)

    def test_invalid_palette_does_not_replace_committed_state(self):
        with tempfile.TemporaryDirectory() as folder:
            home=Path(folder); state=home/'.local/state/siverteh_shell'; (state/'scheme').mkdir(parents=True)
            current=state/'scheme/current.txt'; current.write_text('previous palette')
            (state/'scheme.json').write_text(json.dumps({'mode':'light','colours':{'primary':'not a hex color'}}))
            with self.assertRaises(ValueError): palette.apply_palette(home, live=False)
            self.assertEqual(current.read_text(), 'previous palette')
            self.assertFalse((home/'.config/siverteh-shell/palette.lua').exists())

if __name__ == '__main__': unittest.main()
