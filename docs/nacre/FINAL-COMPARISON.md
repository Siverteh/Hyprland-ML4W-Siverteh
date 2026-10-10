# Final current-source and runtime comparison

Review date: 2026-10-10. Baseline main:
`4dee23484a32f843dab319afe42c9eeae83481fd`; final verification follows
[the specification](../specs/final-provenance-comparison.md). Exact final file
hashes are in the registry. This document joins the area origin records, source
comparison, dependency boundaries and live evidence; a similarity score or green
test alone is not the completion claim.

## Requirement and evidence map

| Requirement | Evidence and scope |
|---|---|
| Independent palette engine | [Orient source audit](ORIENT-SOURCE-AUDIT.md): eight own modules, public equations/Pillow, no inherited generator/import; Natural default and Harmony optional |
| Foundation/config/frame | [Foundation](FOUNDATION-SOURCE-AUDIT.md), [core composition](CORE-PRESENTATION-SOURCE-AUDIT.md), initial replacement records in [provenance](PROVENANCE.md) |
| Launcher/wallpapers/notices/dashboard/Settings/bar/popups/OSD/session/background | [Application panels](APPLICATION-PANELS-SOURCE-AUDIT.md) and core presentation reviews; all current bodies/adapters individually covered |
| Native/data/lifecycle services and remaining helpers | [Services](SERVICES-SOURCE-AUDIT.md), [persistence](PERSISTENCE-SOURCE-AUDIT.md), [device/session](DEVICE-SESSION-SOURCE-AUDIT.md), [startup](DESKTOP-STARTUP-SOURCE-AUDIT.md) |
| Publisher, generated palettes, branding and lock/login/Files | [Palette data](PALETTE-DATA-SOURCE-AUDIT.md), [login/Files](LOGIN-FILES-SOURCE-AUDIT.md), specs/area records for publication, branding, fonts and lock presentation |
| ML4W config/helper leftovers | Fresh Lua/Kitty/Fastfetch source and [configuration helpers](CONFIG-HELPER-SOURCE-AUDIT.md); Matrix/hide helper replaced, dead code retired |
| AI/Brain and fixtures beyond the initial list | [AI controllers](AI-CONTROLLER-SOURCE-AUDIT.md), [AI bootstrap](AI-BOOTSTRAP-SOURCE-AUDIT.md), [knowledge helpers](KNOWLEDGE-HELPER-SOURCE-AUDIT.md), [Brain](BRAIN-CORE-SOURCE-AUDIT.md), [Brain integrations](BRAIN-INTEGRATION-SOURCE-AUDIT.md), [native fixtures](NATIVE-FIXTURE-SOURCE-AUDIT.md), [Python fixtures](PYTHON-FIXTURE-SOURCE-AUDIT.md) |
| Deployment owners/native dependency credit | [Packaging](PACKAGING-SOURCE-AUDIT.md); native Quickshell backport separately LGPL, not Nacre-original code |
| All current documentation/metadata | [Guides](DOCUMENTATION-GUIDE-AUDIT.md), [remaining guides/notices](REMAINING-GUIDES-NOTICES-AUDIT.md), full historical reader/history/structure review below |
| No active inherited runtime | Exact managed/current/good/helper/Orient copies, native package/process trace and fresh-compositor evidence below |
| Preserve private state/policies/busy workers | No account/vault/browser/host preference migration; full-access Codex/Claude and paru --skipreview retained; persistent worker identity checked across deployments |
| Publication and validation | Full native/source tests, Hyprland parser, reviewed plan/apply and live source/IPC gates; exact-main CI required for the final revision |

The registry covers the complete Git index, including code, configuration, data,
assets, helpers, tests and metadata. No artifact is certified by directory/name,
first Git addition or low similarity alone. It retains individual source histories,
specs, replacements and current hashes. Previous exposure is acknowledged.

## Upstream inputs and reproducible method

Source snapshots are selected from public Git trees, before requesting blob data.
Binary wallpaper/font payloads and symlink targets are not extracted or executed.
The selection includes Python/QML/JS/Lua/shell/config/JSON/CSS/SVG/Fish/Rofi,
HTML/XML/TypeScript, documentation, service/timer files and extensionless metadata.
Native third-party code/assets outside this comparison retain their separate audits.

| Input | Immutable revision | Selected files |
|---|---|---|
| Caelestia reference-period shell | `c63f1b7e00e475eb68e4210590f515054eea2ea6` | 110 |
| Caelestia CLI before local import | `b698f7a38543df7139c6f8ae3c748cb07c69769e` | 91 |
| Caelestia CLI June variant | `f16ec8f54e3dd60a47a73aaab75d0ad64e5025f6` | 51 |
| ML4W before the original checkout | `a4ea0b4b85bb6ac2b98e85436487dcaa01735bcb` | 439 |

The reference-period shell was selected by comparing original-import Git blob IDs
against May/June 2025 snapshots. Three June 9 revisions share the best 81 exact
QML/JS blob matches; this pins one of those tied snapshots rather than pretending
the original upstream revision was recorded. CLI/ML4W snapshots are dated before
their respective local imports; the additional June CLI catches its earlier form.

The comparison reads the complete current tracked artifact bytes. Exact matches
use SHA-256. The secondary scan strips blank/full-line comment/import lines,
whitespace and Nacre/Caelestia/Siverteh name prefixes, while retaining substantive
line order. Three-line seeds identify candidates; SequenceMatcher with autojunk
off locates contiguous blocks. Reported blocks require at least six substantive
lines and 150 characters. These thresholds select review candidates, not a legal
originality boundary. Reordered/short/copied ideas can escape such a scan; histories,
full-body origin reviews and public contract evidence remain necessary.

The non-document/license scan covers 557 baseline artifacts. It finds no exact
file copies and one qualified match: eight Kitty option/value declarations,
160 normalized characters. Its fresh composition (`3bf8870`), prewritten behavior
spec, recorded native parser baseline and measured font/geometry policy account
for those public declarations. Values are retained to preserve the user's preferred
behavior, not shuffled to lower a score. No inherited comment/control/template
body remains in that file.

Positive controls run the same method on the historical imports: 107 shell QML/JS
files yield 83 exact matches and 96 files with qualified blocks; 17 old CLI modules
yield seven exact matches and 15 with blocks. Examples include the old 373-line
Media, 321-line notification and 199-line palette generator blocks. This shows the
method detects the known imports; it still cannot establish authorship by itself.
The removed MIT fuzzysort library appears among historical controls, not current
code. Third-party origins are distinguished rather than declared Nacre inventions.

A supplementary whole-index scan reads all 702 working-tree artifacts over base
`a79cdd65331322a659c7eca310bc22926af029ac`, including documentation and license texts.
Its three exact matches are the canonical GNU GPL documents in the shell, CLI and
native dependency credits. Its 16 qualified blocks are those generic license texts
plus the same Kitty declarations; there is no additional document/code match.
These legal texts belong to the Free Software Foundation, not Caelestia/ML4W
implementation. Source-only results remain 557 artifacts. The final committed
revision must be rerun, with metadata bytes anchored independently as below.

## Historical documents and registry metadata

A fresh read-only reader read all 87 pending Markdown bodies at `a79cdd6`,
7,517 lines/544,933 bytes, with every truncation repaired, including the full
2,210-line provenance ledger. They are local specifications, dated source audits
and index/status prose. Inline content is public command/API/scalar contracts,
hashes and audit tables; no fenced executable implementation appears.

Full local creation/change histories tie these documents to the independent
specification/replacement/audit commits, outside the original imported sources.
Current guides have separate source/reader reviews. Historical status, retired
startup/Matrix contracts, license-path wording and an orphan table row are clarified
without erasing the dated evidence. The deployment-probe prohibition now distinguishes
concurrent interference/preferences/device changes from required panel gates.

The JSON registry is own audit metadata, not executable vendor implementation.
Structural checks validate all tracked paths/dispositions/evidence/hash bindings;
Git history traces its authoring and additions. It deliberately has no circular
self-review. `provenance.py --complete --metadata-revision COMMIT` requires every
other artifact to be reviewed/current/not inherited and compares full registry
bytes to that immutable Git commit. CI records the exact commit and metadata hash.
This anchors metadata integrity; it does not turn a JSON entry into authorship proof.

## Active source and dependency boundary

Allowlisted inspection on the running host found:

- 38 managed configuration files, 231 current and 231 good shell implementation
  files, and 61 deployed helper files exactly match the reviewed source.
- All eight active Orient Python modules match source. Its isolated distributions
  are nacre_shell 2.0.0, Pillow 12.3.0 and pip 26.2.1; there is no Caelestia/Material
  You package or imported implementation.
- The live renderer executes `/usr/bin/quickshell`, owned by pacman. Native Thunar,
  Xfconf, Qt plugins and Papirus are likewise system packages. The renderer has no
  LD_LIBRARY_PATH/Qt import/plugin override or legacy private-native PATH entries.
- Brain's eight deployed application files match source; the independent persistent
  sidebar worker stays alive. Desktop action/appearance owners do not require Brain.
- Compatibility paths and dormant release/package backups remain for recovery.
  They are not imports or active native library owners. No user state is removed
  merely to eliminate a historical name.

Stock font files are pinned official licensed dependencies outside Git. The current
tracked tree contains no binary artwork/font payload. The only SVG is the reviewed
local SH geometry. Runtime Papirus overlays link to its separately GPL artwork;
Material Symbols, Plex/Rubik, Pillow and native libraries retain their own notices.
The four numeric illustration fixture records retain CC BY-SA 4.0 attribution.
Quickshell's native compatibility patch remains upstream LGPL v3 with author/source
credit and full incorporated GPL text. No third-party material is relicensed here.

A fresh native Hyprland 0.56.2 process loaded the current managed composition in
Bubblewrap, suppressing external startup/cursor hooks and excluding private
preferences. Its actual IPC reports exactly four Nacre curves plus default/linear,
35 nodes and no configuration errors. The sandbox exposes no KMS cards or buses;
owned rule/process cleanup restores parent focus/workspace. The live graph uses
only these Nacre/native curve IDs. Old registrations left by reload are unused
native cache data. This closes the explicit fresh-process follow-up, without
claiming physical login/private-profile/timing acceptance.

## Attribution, scope and final gates

The maintained implementation and active-runtime evidence substantiate no remaining
Caelestia/ML4W-derived executable/config/template/asset body or required runtime.
Historical credits/source remain in Git and dated provenance. Current notices
accurately identify Nacre's replacement rather than claiming present Caelestia
implementation. Generic GPL-3.0-only license files retain the current project
license choice; the general public release can make its own deliberate licensing
choice later. Third-party exceptions/credits remain explicit.

This is a documented technical provenance conclusion, not a legal clean-room
or universal copyright guarantee. Native APIs, compatible role names, mandated
scalar preferences and properly licensed dependencies are allowed, rather than
pretending every underlying technology was invented here. Prior exposure and the
comparison's limitations remain public.

The final local/native/source checks, reviewed plans and any necessary deployment,
live source/IPC/configerrors and exact-main CI must pass before marking the goal
complete. The metadata completion gate prevents pending/stale/inherited files from
being silently reintroduced. Its isolated real-Git tests cover immutable metadata,
failed source dispositions, circular reviews and machine-readable output.

Reported title/Spotlight/2×2 controls/popup/scroll/motion regressions are the user's
explicit next cleanup goal; this audit does not claim them fixed. Physical cold
login, external display, suspend/unlock and broad visual acceptance remain bounded
hardware/UI checks. Public extraction into nacre-desktop/nacre remains later.
