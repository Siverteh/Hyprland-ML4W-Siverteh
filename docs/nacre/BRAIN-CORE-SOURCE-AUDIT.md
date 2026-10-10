# Brain application core current-source audit

2026-10-10 UTC. Complete current controller (1,023 lines), discovery (649), web
app (1,170 after correction), stylesheet (1,038) and three fixture bodies read.
Local creation/change histories and native/private workflow contracts reviewed.
Controller/original stylesheet authored e42b701; current discovery authored
543ee68 with identical parsed syntax tree today; redesigned current browser UI
and its own check authored b0632b9, followed by local discovery/search/grouping
features and formatting. Current full bodies, not small caller patches, are the
subject of retention. No bundled web library implementation or downloaded model
asset appears in these files; browser/Python/native/model APIs remain dependencies.

Controller owns private Markdown indexing, dated activity, explicit references,
derived grouping/cache/search, narrow actions, authenticated localhost HTTP and
browser ownership/startup. Discovery implements local lexical/optional semantic
scoring, explicit annotations, deduplication, stable communities and reviewable
suggestions. Web client uses native DOM/SVG/fetch, request identity, visibility
polls and text-node Markdown rendering; CSS styles the local two-column workspace
and reader. Unused old CSS selectors/cascade cleanup is own-code maintenance for
the later visual cleanup, not an inherited dependency.

This retention is full-body/history/interface evidence, not a legal clean-room
claim or final whole-upstream comparison. Prior source exposure is acknowledged;
no Caelestia/ML4W implementation was consulted/copied for writing corrections.
All notices remain until complete source/assets/fixtures/docs/dependency review.

Disposable browser fixture exposed a genuine search transition bug: while reading,
the backend returned seven matching synthetic notes but the page remained in read
mode, showing zero results and a visible reader. The earlier browser check could
mistake related reader rows for results. ad0ec60 changes input to notes view and
clears selected reader; the stronger browser check requires visible result rows
inside #content and a hidden reader. Baseline diagnosis records read/7/0/visible;
corrected fixture passes the complete browser sequence.

Native headless Chrome used a disposable profile, temporary HTTP server/auth and
synthetic vault (three subjects, ten notes), with semantics disabled. No live notes,
tokens, existing browser/profile, model download, provider/device actions or service
restart for QA. Tests exercise actual current server, cookie bootstrap, producer
and web assets. Browser check covers overview, real CDP map click, reader, refresh
identity, full-text search, Markdown safety, dynamic subjects, confidence filtering,
light palette and 900/720/420 pixel responsiveness with zero runtime exceptions.
Synthetic search and 420-pixel screenshots inspected; this does not certify every
real-world visual/assistive/physical-login state. Private test artifacts remain
outside Git; only source records are committed.

| Current artifact | Local basis | Later changes | Current SHA-256 |
|---|---|---|---|
| `brain/control.py` | `e42b701` | 548f0b4, 0f9fd41, 69aad30, de8222b, 3f4132d, ba5e48f, bb46dd6, 83b3531, 2fa3a95, ddb0066, c288484, 543ee68, b0632b9, 007d020, a8b816f, 1bcce9d | `63ddc5b631a38177cfdd055003641b7be5e3aa0469d9db7a8beab322cb19be64` |
| `brain/discovery.py` | `543ee68` | 83b3531, 2fa3a95 | `710faa19d9b767831d902e60ef80cad0c8e39b0e1e64d7bbb10beefd8cf365e5` |
| `brain/web/app.js` | `b0632b9` | ad0ec60, d5d8dbd, 2fa3a95, 543ee68 | `af2a9f6b54cee50cfc612224b1b919ed59ead1b4f8d794274b5b8c9a8c682453` |
| `brain/web/style.css` | `e42b701` | d5d8dbd, 2fa3a95, 543ee68, b0632b9, a8b816f | `77b942a8a89cf982a4f259d7d2264512d01f12182751d15c4d4a34c8c4e03411` |
| `brain/tests/test_index.py` | `e42b701` | 7cc8f33, 0f9fd41, 3f4132d, ba5e48f, fc19a5d, 83b3531, 2fa3a95, ddb0066, c288484, 543ee68, b0632b9, 1bcce9d | `894d34843df50e87f8d85c9871b44f02cb4c6ff30a63d1a5fb86dd1dd54f263b` |
| `brain/tests/test_discovery.py` | `543ee68` | 548f0b4, 83b3531, 2fa3a95 | `d1fafae8c83ba027bc2ab86e004dbb2678985c820f61eb2b4953c43164b7eb7f` |
| `brain/tests/browser-check.mjs` | `b0632b9` | ad0ec60, 2fa3a95, 543ee68 | `8b6cd3d91f6260086978d5dda44c3854b2385f9d28316be22d3746d86d74117b` |

Candidate validation: all 434 tests passed (72 tools, 98 AI, 35 Brain, 229 shell),
with native QML/Lua, Ruff, palette CLI and JavaScript checks. Native Hyprland
verification passed; reviewed Brain component plan and config plan (zero files/
migrations). Browser fixture passed separately against the current authenticated
server/assets with disposable data/profile; no existing user's browser was used.

Deployment: Brain component release 20261010T060928326683Z promoted good at
source 0f235190fa6e9423adce4914176fc919a009be94. Transaction repeated all 434 tests,
Brain readiness, real launcher/wallpaper Escape gates and native service checks.
All eight Brain source/assets and the actual served JavaScript match candidate
bytes. Only the Brain source target changed among release snapshots; managed
config, UI and palette-runtime fingerprints stayed the same. Running sidebar
backend PID/start time unchanged; current/good UI source exact, services and
frame/palette IPC healthy, config errors empty. Browser data stays external;
existing page refresh was not forced or used as a private-data test. The revised
client is available on normal reload. Whole-tree comparison/licensing still open.
