import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('window_rules', Path(__file__).parents[1] / 'window_rules.py')
rules = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rules)


class WindowRuleTests(unittest.TestCase):
    def test_alternation_and_case_pair_detect_conflicting_routes(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / 'one.lua').write_text('hl.window_rule({match={class="^(Code)$"},workspace="2 silent"})')
            (root / 'two.lua').write_text('hl.window_rule({match={class="^([Cc]ode|Cursor)$"},workspace="7 silent"})')
            self.assertTrue(rules.conflicts(root))

    def test_identical_class_float_conflict_and_compatible_rules(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / 'one.lua').write_text('hl.window_rule({match={class="^(app)$"},float=true})')
            (root / 'two.lua').write_text('hl.window_rule({match={class="^(app)$"},float=false})')
            self.assertIn('float', rules.conflicts(root)[0])
            (root / 'two.lua').write_text('hl.window_rule({match={class="^(app)$"},float=true})')
            self.assertEqual(rules.conflicts(root), [])

    def test_title_scoped_exception_is_not_a_class_wide_conflict(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / 'one.lua').write_text('hl.window_rule({match={class="^(app)$"},float=false})')
            (root / 'two.lua').write_text('hl.window_rule({match={class="^(app)$",title="^(dialog)$"},float=true})')
            self.assertEqual(rules.conflicts(root), [])
