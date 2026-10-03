# Siverteh Brain

The private knowledge browser follows the current wallpaper palette and angular SH branding. Its persistent app stays on workspace6; Super+B brings it forward. The compatibility command/service paths retain the observatory name so existing shortcuts and sessions continue to work.

## Browse

- Overview shows dynamically discovered subjects, dated-evidence activity, recent knowledge and subjects sharing notes.
- Connections shows a focused, labeled map. Select a subject/topic/note to change its neighborhood; Back/Escape returns. Solid lines are grouping/shared evidence; dashed lines are explicit references.
- Notes supports full-text search, confidence filters and incremental results. Ctrl+K focuses search.
- Select a note to open it in the main workspace, with formatted Markdown and tables. There is no right sidebar. Wiki and Markdown links navigate locally; References and Referenced by distinguish direction. Metadata is folded under Note details.
- Refresh preserves the selected note and its reader when content has not changed. Changes are checked every30s while visible; no continuous render loop, WebGL, CDN, telemetry or model call is required.

Subjects and topics come from the existing private vault, world/topic annotations and project registry. Associations suggested by text are labeled and are not verified dependencies. Dated evidence uses the existing21-day activity half-life/daily cap; it does not count every chat message. Older knowledge remains available.

## Deploy

Run `python3 rice/observatory/deploy-brain.py` from the selected checkout. This deploys only web assets/control.py and updates only the AI launcher's select-menu function. It backs up those components privately and restarts the dedicated brain service/profile. It does not reinstall the old desktop shell, change wallpaper/theme preferences, rewrite notes, copy authentication or interrupt other assistants/browser profiles. Existing launcher windows need reopening to show new branding.

The loopback server remains127.0.0.1:17843. Hidden state/instruction files and external symlinks are excluded from the index/search; note reads enforce the vault boundary. Actions require same-origin JSON and an allowlist. Notes are rendered with DOM text nodes, not trusted as HTML. Knowledge/activity has no public synchronization via this OS repository.

## Verify

`python3 -m unittest discover -s rice/observatory/tests` verifies index/search/link boundaries and dynamic subjects. AI workflow tests remain under ai/tests.

For browser checks, run a separate instance of Handler on17845 and isolated headless Chrome CDP on17946, then `siverteh-ai-tools node rice/observatory/tests/browser-check.mjs`. Ports/URL can be overridden through BRAIN_TEST_CDP/BRAIN_TEST_URL. Checks cover map clicks, reader, full-text search, confidence isolation, dynamic subjects, safe Markdown, light palette and narrow layouts. Screenshots stay in the private user state directory. This browser test is separate from the persistent brain window and authenticated browsers.
