import concurrent.futures
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import stat
import shutil
import subprocess
import sys
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]


def module(name):
    loader = importlib.machinery.SourceFileLoader(name.replace('-', '_'), str(ROOT / 'bin' / name))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    loaded = importlib.util.module_from_spec(spec)
    loader.exec_module(loaded)
    return loaded


class BrainTests(unittest.TestCase):
    def test_note_metadata_cannot_bypass_common_secret_checks(self):
        with tempfile.TemporaryDirectory() as tmp:
            for field in ('--title', '--source'):
                argv = [sys.executable, str(ROOT / 'bin/siverteh-brain'), 'note', '--title', 'Title', '--source', 'Source']
                argv[argv.index(field) + 1] = 'password: example-private-value'
                result = subprocess.run(argv, input='Ordinary body', text=True, env=dict(os.environ, SIVERTEH_BRAIN=tmp), capture_output=True)
                self.assertNotEqual(result.returncode, 0)
            self.assertEqual(list((Path(tmp) / 'inbox').glob('*.md')), [])

    def test_concurrent_notes_are_private_and_distinct(self):
        with tempfile.TemporaryDirectory() as tmp:
            vault = Path(tmp) / 'private'
            env = dict(os.environ, SIVERTEH_BRAIN=str(vault))
            # Initialization is done by installation before concurrent writers.
            subprocess.run([sys.executable, str(ROOT / 'bin/siverteh-brain'), 'init'], env=env, check=True, capture_output=True)
            def write(index):
                return subprocess.run([sys.executable, str(ROOT / 'bin/siverteh-brain'), 'note', '--title', 'Concurrent fact', '--source', 'test evidence', '--confidence', 'verified'], input=f'Observation {index}', text=True, env=env, check=True, capture_output=True).stdout.strip()
            with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
                paths = list(pool.map(write, range(16)))
            self.assertEqual(len(set(paths)), 16)
            self.assertEqual(stat.S_IMODE(vault.stat().st_mode), 0o700)
            for index, name in enumerate(paths):
                self.assertIn(f'Observation {index}', Path(name).read_text())
                self.assertEqual(stat.S_IMODE(Path(name).stat().st_mode), 0o600)

    def test_common_secret_values_are_rejected_but_references_allowed(self):
        brain = module('siverteh-brain')
        for text in ['password: example-private-value', '-----BEGIN OPENSSH PRIVATE KEY-----', 'sk-proj-' + 'x' * 30]:
            with self.assertRaises(ValueError):
                brain.safe_note(text)
        brain.safe_note('Credential reference: secret-service://siverteh-brain/development')

    def test_failed_note_does_not_create_a_note_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            env = dict(os.environ, SIVERTEH_BRAIN=tmp)
            result = subprocess.run([sys.executable, str(ROOT / 'bin/siverteh-brain'), 'note', '--title', 'Blocked', '--source', 'test'], input='refresh_token: test-private-value', text=True, env=env, capture_output=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(list((Path(tmp) / 'inbox').glob('*.md')), [])


class WorkflowTests(unittest.TestCase):
    def test_dashboard_forwards_selected_account_to_worker(self):
        ai = module('siverteh-ai')
        with patch.object(sys, 'argv', ['siverteh-ai', 'dashboard', '--account', 'second']), patch.object(ai, 'select', side_effect=['New task', 'Close dashboard']), patch.object(ai, 'project_for', return_value={'id': 'example-project'}), patch.object(ai.subprocess, 'Popen') as launch:
            ai.main()
            self.assertEqual(launch.call_args.args[0][-4:], ['--project', 'example-project', '--account', 'second'])

    def test_remote_wrapper_protects_legacy_home_and_honors_separate_accounts(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            binary = home / '.local/share/siverteh-ai/codex/packages/0.159.2/bin/codex'
            binary.parent.mkdir(parents=True)
            binary.write_text('#!/bin/sh\nprintf "%s\\n" "$CODEX_HOME"\n')
            binary.chmod(0o755)
            for selected, expected in [(home / '.codex', home / '.local/share/siverteh-ai/codex-home'), (home / '.local/share/siverteh-ai/accounts/second', home / '.local/share/siverteh-ai/accounts/second')]:
                result = subprocess.run(['bash', str(ROOT / 'ai/remote-codex-wrapper.sh')], env=dict(os.environ, HOME=tmp, CODEX_HOME=str(selected)), capture_output=True, text=True, check=True)
                self.assertEqual(result.stdout.strip(), str(expected))

    def test_remote_session_selection_distinguishes_account_prefixes(self):
        ai = module('siverteh-ai')
        project = {'id': 'project', 'host': 'my-server', 'path': '/tmp/project'}
        wanted = 'ai-project-profile-work-20260930T140000-123'
        listing = SimpleNamespace(stdout=wanted + '\nai-project-profile-work-personal-20260930T140000-456\nai-project-default-20260930T140000-789\n')
        with patch.object(ai, 'project_for', return_value=project), patch.object(ai.subprocess, 'run', return_value=listing), patch.object(ai, 'select', return_value=wanted) as select, patch.object(ai.os, 'execvp', side_effect=RuntimeError('exec intercepted')):
            with self.assertRaisesRegex(RuntimeError, 'exec intercepted'):
                ai.run_project(SimpleNamespace(command='sessions', project='project', account='work'))
            self.assertEqual(select.call_args.args[0], [wanted])

    def test_remote_account_is_forwarded_without_shell_injection(self):
        ai = module('siverteh-ai')
        project = {'id': 'project', 'host': 'my-server', 'path': '/tmp/project with spaces'}
        with patch.object(ai, 'project_for', return_value=project), patch.object(ai.os, 'execvp', side_effect=RuntimeError('exec intercepted')) as call:
            with self.assertRaisesRegex(RuntimeError, 'exec intercepted'):
                ai.run_project(SimpleNamespace(command='new', project='project', account='second'))
            args = call.call_args.args[1]
            self.assertEqual(args[:3], ['ssh', '-t', 'my-server'])
            self.assertIn("'/tmp/project with spaces' second", args[3])
            with self.assertRaises(ValueError):
                ai.run_project(SimpleNamespace(command='new', project='project', account='../../escape'))

    def test_account_helper_preserves_default_auth_and_uses_isolated_home(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            (home / '.codex').mkdir()
            (home / '.codex/auth.json').write_text('default authentication')
            (home / '.codex/AGENTS.md').write_text('shared guidance')
            fake = home / 'fake'
            fake.mkdir()
            (fake / 'codex').write_text('#!/bin/sh\nprintf "%s\\n" "$CODEX_HOME"\n')
            (fake / 'codex').chmod(0o755)
            result = subprocess.run([sys.executable, str(ROOT / 'bin/siverteh-ai-account'), 'second', 'login'], env=dict(os.environ, HOME=tmp, PATH=str(fake) + ':' + os.environ['PATH']), text=True, capture_output=True, check=True)
            profile = home / '.local/share/siverteh-ai/accounts/second'
            self.assertEqual(result.stdout.strip(), str(profile))
            self.assertEqual((home / '.codex/auth.json').read_text(), 'default authentication')
            self.assertFalse((profile / 'auth.json').exists())
            self.assertTrue((profile / 'AGENTS.md').is_symlink())

    def test_separate_account_home_keeps_shared_guidance_without_auth_copy(self):
        ai = module('siverteh-ai')
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {'HOME': tmp}):
            codex = Path(tmp) / '.codex'
            codex.mkdir()
            (codex / 'AGENTS.md').write_text('Personal guidance')
            (codex / 'auth.json').write_text('existing account data')
            first = Path(ai.local_environment('first')['CODEX_HOME'])
            second = Path(ai.local_environment('second')['CODEX_HOME'])
            self.assertNotEqual(first, second)
            self.assertEqual((first / 'AGENTS.md').resolve(), codex / 'AGENTS.md')
            self.assertFalse((first / 'auth.json').exists())
            self.assertEqual((codex / 'auth.json').read_text(), 'existing account data')
            with self.assertRaises(ValueError):
                ai.local_environment('../escape')

    def test_project_registry_rejects_shell_host_syntax(self):
        ai = module('siverteh-ai')
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'projects.json'
            path.write_text(json.dumps({'projects': [{'id': 'project', 'path': '/tmp/repo', 'host': 'server; command'}]}))
            with patch.dict(os.environ, {'SIVERTEH_AI_PROJECTS': str(path)}), self.assertRaises(ValueError):
                ai.projects()

    def test_install_preserves_existing_guidance_credentials_and_registry(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            (home / '.codex').mkdir()
            (home / '.codex/AGENTS.md').write_text('Existing user rule\n')
            (home / '.codex/auth.json').write_text('Existing account data')
            (home / '.config/siverteh-ai').mkdir(parents=True)
            registry = home / '.config/siverteh-ai/projects.json'
            registry.write_text('{"projects": []}')
            env = dict(os.environ, HOME=tmp)
            for _ in range(2):
                subprocess.run([sys.executable, str(ROOT / 'ai/install.py')], env=env, check=True, capture_output=True)
            guidance = (home / '.codex/AGENTS.md').read_text()
            self.assertTrue(guidance.startswith('Existing user rule'))
            self.assertEqual(guidance.count('<!-- siverteh-ai-guidance -->'), 1)
            self.assertEqual((home / '.codex/auth.json').read_text(), 'Existing account data')
            self.assertEqual(registry.read_text(), '{"projects": []}')
            self.assertTrue((home / '.agents/skills/siverteh-brain').is_symlink())

    def test_installer_preserves_foreign_guidance_symlink_target(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            foreign = home / 'other-public-repository/AGENTS.md'
            foreign.parent.mkdir()
            foreign.write_text('Existing external rule\n')
            (home / '.codex').mkdir()
            guidance = home / '.codex/AGENTS.md'
            guidance.symlink_to(foreign)
            subprocess.run([sys.executable, str(ROOT / 'ai/install.py')], env=dict(os.environ, HOME=tmp), check=True, capture_output=True)
            self.assertEqual(foreign.read_text(), 'Existing external rule\n')
            self.assertFalse(guidance.is_symlink())
            self.assertTrue(guidance.read_text().startswith('Existing external rule'))
            backups = list((home / '.local/state/siverteh-ai/backups').glob('*/.codex/AGENTS.md'))
            self.assertEqual(len(backups), 1)
            self.assertTrue(backups[0].is_symlink())

    def test_reinstall_refreshes_owned_guidance_pointer_after_checkout_move(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            (home / '.codex').mkdir()
            (home / '.codex/AGENTS.md').write_text('Existing user rule\n')
            env = dict(os.environ, HOME=tmp)
            subprocess.run([sys.executable, str(ROOT / 'ai/install.py')], env=env, check=True, capture_output=True)
            moved = home / 'moved-checkout'
            shutil.copytree(ROOT, moved)
            subprocess.run([sys.executable, str(moved / 'ai/install.py')], env=env, check=True, capture_output=True)
            guidance = (home / '.codex/AGENTS.md').read_text()
            self.assertIn(str(moved / 'ai/AGENTS.md'), guidance)
            self.assertNotIn(str(ROOT / 'ai/AGENTS.md'), guidance)
            self.assertEqual(guidance.count('<!-- siverteh-ai-guidance -->'), 1)


if __name__ == '__main__':
    unittest.main()
