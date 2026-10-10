# Nacre Brain

Nacre Brain is the private knowledge browser. Open it from the app launcher,
with `nacre-brain`, or with Super+B; its persistent window stays on workspace6.
Its palette-colored shell mark includes a small brain beneath the right lip.
Commands, services and private paths now use Nacre names. Old paths and commands
remain aliases for existing sessions. See [the naming guide](../docs/features/nacre-brain.md).

## Browse

- Overview shows dynamically discovered subjects, dated-evidence activity, recent knowledge and subjects sharing notes.
- Connections shows a focused, labeled map. Select a subject/topic/note to change its neighborhood; Back/Escape returns. Solid lines are grouping/shared evidence; dashed lines are explicit references.
- Notes supports full-text search, confidence filters and incremental results. Ctrl+K focuses search.
- Select a note to open it in the main workspace, with formatted Markdown and tables. There is no right sidebar. Wiki and Markdown links navigate locally; References and Referenced by distinguish direction. Metadata is folded under Note details.
- Refresh preserves the selected note and its reader when content has not changed. Changes are checked every30s while visible; no continuous render loop, WebGL, CDN, telemetry or model call is required.

Subjects and topics emerge from the private vault, world/topic annotations and local semantic communities; the coding registry is not used. See DISCOVERY.md for research, rules, performance and limits. Associations suggested by text are labeled and are not verified dependencies. Dated evidence uses a21-day activity half-life, deduplication and diminishing daily returns; it does not count every chat message. Older knowledge remains available.

## Deploy

Optional semantic setup: run `siverteh-ai-tools python brain/provision-semantic.py` once to create an isolated CPU environment and download public model weights. No vault documents are sent during setup. Then deploy the brain. Without this environment, the index reports its lexical fallback and remains usable.

For ordinary deployment, run `./install.sh --component brain` to inspect the plan,
then `./install.sh --apply --component brain` from a clean committed checkout.
The managed release invokes `brain/install.py` to deploy code, its wrapper and service. It backs up those components privately and restarts the dedicated brain service while preserving its browser profile. It does not reinstall the old desktop shell, change wallpaper/theme preferences, rewrite notes, copy authentication or interrupt other assistants/browser profiles. Existing launcher windows need reopening to show new branding.

The loopback server remains127.0.0.1:17843. Hidden state/instruction files and external symlinks are excluded from the index/search; note reads enforce the vault boundary. Non-health API requests require a restart-safe browser cookie. The bootstrap
token rotates per server start and stays in private mode-0600 state. Actions also require same-origin JSON and an allowlist. Notes are rendered with DOM text nodes, not trusted as HTML. Knowledge/activity has no public synchronization via this OS repository.

## Verify

`python3 -m unittest discover -s brain/tests` verifies index/search/link boundaries and dynamic subjects. AI workflow tests remain under ai/tests.

For browser checks, create a separate `BrainServer` with synthetic notes, disposable
HOME/XDG state and an isolated headless Chrome profile. Authenticate that fixture
through its own bootstrap URL before running
`siverteh-ai-tools node brain/tests/browser-check.mjs`. Use BRAIN_TEST_CDP and
BRAIN_TEST_URL to select the isolated debug port and authenticated fixture URL.
Never point this harness at the live vault or an existing browser profile. Checks cover map clicks, reader, full-text search, confidence isolation, dynamic subjects, safe Markdown, light palette and narrow layouts. Screenshots stay in the private user state directory. This browser test is separate from the persistent brain window and authenticated browsers.

Grouping corrections are available in the main note reader. The original note and factual confidence are preserved. The brain starts tiled inside the desktop frame, keeping the bar visible.
