import importlib.util,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
spec=importlib.util.spec_from_file_location('sidebar',Path(__file__).resolve().parents[1]/'sidebar-chat.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
class SidebarTests(unittest.TestCase):
 def manager(self,root):
  return patch.multiple(module,HOME=root,STATE=root/'state'),patch.object(module,'preferences',return_value=('codex',''))
 def test_history_preserves_roles_and_updates_streamed_message_in_place(self):
  with tempfile.TemporaryDirectory() as directory:
   p,q=self.manager(Path(directory))
   with p,q:
    manager=module.Manager();manager.delta('reply','Hello');manager.delta('reply',' world');manager.complete_message('reply','Hello world!')
    self.assertEqual(len(manager.messages),1);self.assertEqual(manager.messages[0]['text'],'Hello world!')
    manager.restore([dict(items=[dict(id='u',type='userMessage',content=[dict(type='text',text='Question')]),dict(id='a',type='agentMessage',text='Answer')])])
    self.assertEqual([m['role'] for m in manager.messages],['user','assistant'])
 def test_questions_require_matching_request_id(self):
  with tempfile.TemporaryDirectory() as directory:
   p,q=self.manager(Path(directory))
   with p,q:
    from unittest.mock import Mock
    manager=module.Manager();peer=Mock();manager.ask(peer,17,[dict(id='choice',question='Choose')],'input')
    manager.handle(dict(action='answer',id='old',answers={}));peer.answer.assert_not_called()
    manager.handle(dict(action='answer',id='17',answers={'choice':{'answers':['A']}}));peer.answer.assert_called_once()
 def test_session_metadata_is_private_and_does_not_copy_messages(self):
  with tempfile.TemporaryDirectory() as directory:
   p,q=self.manager(Path(directory))
   with p,q:
    manager=module.Manager();manager.messages=[dict(id='a',role='assistant',text='Private conversation body')];manager.save()
    self.assertNotIn('Private conversation body',manager.path.read_text());self.assertEqual(manager.path.stat().st_mode&0o777,0o600)
 def test_workspace_releases_peer_before_launch_and_blocks_reconnect(self):
  from unittest.mock import Mock
  with tempfile.TemporaryDirectory() as directory:
   p,q=self.manager(Path(directory))
   with p,q:
    manager=module.Manager();manager.metadata.update(id='fixture-thread',title='Fixture')
    peer=Mock();manager.peer=peer;events=[];peer.close.side_effect=lambda:events.append('closed')
    extras=Mock();extras.resume.side_effect=lambda key:events.append('launched')
    with patch('importlib.util.module_from_spec',return_value=extras),patch('importlib.util.spec_from_file_location'):
     manager.handle(dict(action='workspace'))
    self.assertEqual(events,['closed','launched']);self.assertIsNone(manager.peer)
    self.assertTrue(manager.state()['inWorkspace'])
    with self.assertRaises(RuntimeError):manager.ensure_peer()
    manager.handle(dict(action='send',text='Must not reopen'))
    self.assertFalse(manager.busy)
    manager.handle(dict(action='new'));self.assertFalse(manager.state()['inWorkspace'])
 def test_busy_workspace_handoff_does_not_stop_worker(self):
  from unittest.mock import Mock
  with tempfile.TemporaryDirectory() as directory:
   p,q=self.manager(Path(directory))
   with p,q:
    manager=module.Manager();manager.metadata['id']='fixture';manager.peer=Mock();manager.busy=True
    manager.handle(dict(action='workspace'));manager.peer.close.assert_not_called()
 def test_provider_choice_changes_default_without_converting_current_chat(self):
  from unittest.mock import Mock
  with tempfile.TemporaryDirectory() as directory:
   p,q=self.manager(Path(directory))
   with p,q:
    manager=module.Manager();setter=Mock()
    with patch.object(module.runpy,'run_path',return_value={'set_default_assistant':setter}):
     manager.handle(dict(action='provider',provider='claude'));setter.assert_called_once_with('claude')
     manager.handle(dict(action='provider',provider='unexpected'));self.assertEqual(setter.call_count,1)
    self.assertEqual(manager.metadata['agent'],'codex')
 def test_error_messages_do_not_echo_credentials_or_prompts(self):
  self.assertEqual(module.friendly_error('Invalid secret_key sensitive-value'), 'The assistant could not finish this request. Try again or open AI settings.')
if __name__=='__main__':unittest.main()
