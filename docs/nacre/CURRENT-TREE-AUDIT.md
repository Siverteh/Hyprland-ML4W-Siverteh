# Whole-current-tree provenance audit

The initial review listed selected inherited files. Completion needs an audit of
all maintained artifacts, including helpers, generators, fixtures, assets and
configuration outside that list. The current tree and deployed runtime are separate
checks; an old private release backup is not an active runtime dependency.

Run `python3 tools/provenance.py` for counts or add `--json` to inspect every
tracked path, its current SHA-256 and its evidence pointers. The inventory comes
from Git's index, so add new intended files before checking. Untracked personal
state and ignored build products do not enter a public report. Review the actual
runtime separately without committing private paths, artwork or account data.

`current-tree-reviews.json` stores two different types of evidence:

- `change_records` point to documented replacement commits and specs. These are
  historical pointers to changes, including caller/test adjustments. They do not
  prove that every changed file was independently rewritten or that later edits
  remained independent. Paths absent today are omitted from the live inventory.
- `reviews` will record explicit final file dispositions, evidence and SHA-256:
  `independent`, `third-party`, `inherited`, or `non-implementation`. No file is
  automatically certified by its name, directory, timestamp or successful tests.
  New files start pending; changed reviewed content becomes stale. The repository
  check rejects stale or malformed reviews. Pending remains allowed during this
  sustained rewrite and must be resolved before the goal is declared complete.

A final review should trace authoring/replacement history and specs, distinguish
compatibility contracts from inherited implementation, identify third-party
licenses and assess remaining similarity. Hashes tie conclusions to exact bytes;
they cannot establish authorship. Keep original exposure records honest. Keep all
applicable notices until a complete source/asset/dependency review supports their
removal; this tool is not a license decision.

Do not store a second committed copy of the generated whole-tree report: it would
continually become stale, and hashing the report into itself is circular. The
registry is inventoried as an ordinary artifact, with no self-hash review. Final
review evidence for audit metadata can use a separately identified Git revision.

## Next audit groups

1. Mixed shell services and playback/state/recovery/settings/action providers.
2. Remaining extras, widgets and local JavaScript utilities; retire dead code.
3. Palette publisher, wallpaper/weather helpers, branding and lock/login generators.
4. Other Hyprland/terminal/session configs, packaging, deployment and tests.
5. AI/Brain source history and dependency/asset notices, followed by the deployed
   source/runtime comparison. Their personal state remains private.

The earlier verified replacement records remain in `PROVENANCE.md`. Pending
final audit status here does not reverse those functional/live acceptance results.

## CI checkout ownership

GitHub's root-running Arch container reads the runner-owned checkout. CI records
only `$GITHUB_WORKSPACE` as a trusted Git directory in its effective global config
before the index scan; checkout's temporary-home setting did not survive into this
step. No wildcard trust, local-machine trust change, fallback scan or skipped audit.
Git failures include their actual stderr so ownership errors remain actionable.
See [Git safe.directory](https://git-scm.com/docs/git-config#Documentation/git-config.txt-safedirectory)
and [checkout's setting](https://github.com/actions/checkout#usage).
