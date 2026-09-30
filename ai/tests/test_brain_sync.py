import concurrent.futures
import importlib.machinery
import importlib.util
from pathlib import Path
import stat
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
loader = importlib.machinery.SourceFileLoader('brain_sync', str(ROOT / 'bin/siverteh-brain-sync'))
spec = importlib.util.spec_from_loader(loader.name, loader)
sync = importlib.util.module_from_spec(spec)
loader.exec_module(sync)


class SyncTests(unittest.TestCase):
    def test_new_notes_exchange_without_overwrites_or_deletions(self):
        with tempfile.TemporaryDirectory() as tmp:
            left, right = Path(tmp) / 'left', Path(tmp) / 'right'
            left.mkdir()
            right.mkdir()
            sync.merge_new(left, {'inbox/left.md': 'Left note', 'inbox/conflict.md': 'Left edit'})
            sync.merge_new(right, {'inbox/right.md': 'Right note', 'inbox/conflict.md': 'Right edit'})
            added, conflicts = sync.merge_new(right, sync.snapshot(left))
            self.assertEqual(added, ['inbox/left.md'])
            self.assertEqual(conflicts, ['inbox/conflict.md'])
            sync.merge_new(left, sync.snapshot(right))
            self.assertEqual((left / 'inbox/right.md').read_text(), 'Right note')
            self.assertEqual((left / 'inbox/conflict.md').read_text(), 'Left edit')
            self.assertEqual((right / 'inbox/conflict.md').read_text(), 'Right edit')
            self.assertEqual(stat.S_IMODE((left / 'inbox/right.md').stat().st_mode), 0o600)

    def test_secret_and_non_note_paths_are_rejected_before_writes(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for name, body in [('inbox/private.md', 'password: secret'), ('../outside.md', 'ordinary'), ('.codex/auth.json', 'ordinary')]:
                with self.assertRaises(ValueError):
                    sync.merge_new(root, {'inbox/first.md': 'ordinary', name: body})
                self.assertFalse((root / 'inbox/first.md').exists())

    def test_concurrent_duplicate_imports_publish_one_complete_note(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            body = 'Long complete note\n' * 10000
            with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
                results = list(pool.map(lambda _: sync.merge_new(root, {'inbox/same.md': body}), range(16)))
            self.assertEqual(sum(len(added) for added, _ in results), 1)
            self.assertTrue(all(not conflicts for _, conflicts in results))
            self.assertEqual((root / 'inbox/same.md').read_text(), body)
            self.assertEqual(list((root / 'inbox').glob('.sync-*')), [])

    def test_symlinks_cannot_export_or_replace_external_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / 'vault'
            (root / 'inbox').mkdir(parents=True)
            external = Path(tmp) / 'external.md'
            external.write_text('Outside the vault')
            (root / 'inbox/linked.md').symlink_to(external)
            with self.assertRaises(ValueError):
                sync.snapshot(root)
            with self.assertRaises(ValueError):
                sync.merge_new(root, {'inbox/linked.md': 'Changed'})
            self.assertEqual(external.read_text(), 'Outside the vault')


if __name__ == '__main__':
    unittest.main()
