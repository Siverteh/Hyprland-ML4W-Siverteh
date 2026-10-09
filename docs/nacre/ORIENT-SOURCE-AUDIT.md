# Orient implementation origin review

Reviewed 2026-10-09 against the current tree based on `c8d3d69`. This is a
file-level source/dependency review, not a final whole-repository license decision
or an upstream similarity-comparison result. Applicable notices remain.

## Scope and evidence

The eight Python modules and `pyproject.toml` below were read in full. Their
implementation origin is the independent replacement `5ecf556`, with later
locally authored corrections/tuning identified in Git history. The replacement
record/spec describes deletion of inherited bodies before implementation from
CLI/output contracts, tests, primary equations and Pillow APIs. Current source
was inspected for implementation structure, import/dependency flow and compatible
boundary values. No Caelestia/ML4W implementation was consulted in this review.
Historical source exposure remains recorded in the area provenance, rather than
being presented as a legal clean-room guarantee.

| File | Current implementation and origin evidence |
|---|---|
| `__init__.py` | Local engine identity/code fingerprint and lazy entry point; replacement `5ecf556`, identity stabilization `0573f6b` |
| `__main__.py` | Standard Python module entry point, delegates to the local CLI |
| `cli.py` | Fresh argparse scheme/wallpaper commands, private state/hooks and read-only query routing; compatible flags/output schemas are contracts |
| `colour.py` | Own sRGB/OKLab conversion, fixed-hue gamut search and contrast correction using published mathematical equations |
| `engine.py` | Own candidate names/cache validation/image identity and read-only generation; malformed-cache correction `401f63a`, variation `372fe77`, Harmony `9c9089f` |
| `extract.py` | Own bounded Pillow decoding/profile normalization, weighted spatial color families and deterministic ranking; variation `372fe77` |
| `palette.py` | Own role policy, generation/contrast validation and consumer-key mapping; variations `372fe77`, hierarchy and Harmony tuning `9c9089f` |
| `storage.py` | Own XDG path, atomic replacement, file-lock and content-identity helpers from the replacement |
| `pyproject.toml` | Replacement packaging/entry point/Pillow-only runtime declaration; Hatchling is a build dependency |

Paths in the table are under `nacre/shell-cli/src/nacre_shell`, except the package
metadata at `nacre/shell-cli/pyproject.toml`. Exact artifact SHA-256 values and
this review reference are recorded in `current-tree-reviews.json`. A later byte
change makes the review stale and requires reassessing the changed implementation;
do not blindly refresh hashes to satisfy a check. Evidence pointers to changes
in the inventory are deliberately separate from these explicit reviews.

## Dependency boundary

Runtime imports consist of Python's standard library, other modules in this
package and Pillow. No Material You, Caelestia Python package, ML4W helper,
upstream scheme class or old palette data is used by these files. Names such as
`tonalspot`, container roles and terminal color aliases remain compatible
identifiers; the independently written policy generates their values.

The [author's OKLab definition](https://bottosson.github.io/posts/oklab/)
is the mathematical reference. The local conversion and gamut/contrast operations
implement the equations; their publication does not certify unrelated code.
[Pillow's license](https://github.com/python-pillow/Pillow/blob/main/LICENSE) and
[Hatch's license](https://github.com/pypa/hatch/blob/master/LICENSE.txt) cover those
allowed dependencies; no dependency source is copied into this package. Keep
attribution and review all distributed dependencies before a public extraction.

## Current runtime and validation

Read-only import/hash inspection found all eight active installed module bytes
identical to the reviewed source. The isolated environment distribution inventory
was Orient (`nacre_shell` 2.0.0), Pillow 12.3.0 and pip 26.2.1. Existing full suites
exercise extraction, hue/contrast/role contracts, caching, public CLI isolation,
Harmony and fixed-preset regeneration; native presentation/palette readiness
and actual wallpaper/Appearance views cover integration. These are functional
checks supporting this review, not authorship proof by themselves.

This review excludes `shell-tools` publisher/provisioning/query bridge/poster and
branding helpers, generated preset/default files, tests/fixtures, stock assets and
other components. They remain separate file-level audits. Final comparison,
full active-runtime tracing and notice/license decisions remain required before
completing the overall originality goal.
