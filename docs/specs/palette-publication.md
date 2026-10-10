# Independent palette publication and shared file primitives

Spec ready, 2026-10-10 UTC. Area: shell-tools/classic-state.py, its own palette
behavior tests and directly involved publication contracts. Orient extraction,
Natural/Harmony choices, fixed presets and native shell presentation already have
independent implementations; preserve them. Audit the remaining publisher by
actual origin, not by its historical filename or absence of Caelestia imports.

## Origin and implementation boundary

Follow first authoring 4874385, palette synchronization 8afd305, prepared commits
81827c1 and subsequent local GTK/terminal/rotation/file-manager/Orient changes.
Investigate copy ancestry/templates where necessary. Existing signatures and
caller/test/producer contracts are allowed sources; no inherited/upstream bodies
consulted while writing replacements. Previously exposed source/declarations must
be recorded honestly. Retain verified own code; for inherited/uncertain portions,
capture public behavior, delete the body and implement freshly from this spec and
public toolkit/file APIs. Mechanical similarity/history supplement evidence, not
stand alone as originality or license-clearance proof. Keep notices until the
whole-tree conclusion.

## Public interfaces and consumers

Preserve atomic_write(path,text), atomic_symlink(path,target),
commit_prepared(home,wallpaper,data,thumbnail,live=True), luminance(value),
readable(value,background,minimum=4.5), apply_palette(home,wallpaper=None,live=True)
and installed CLI entry point. Shared write primitive is also consumed by sidebar,
notification history, desktop settings/extras; do not break private JSON state or
restart their busy worker. Module imports must not publish files or invoke apps.

Capture inputs, output paths/schemas, role mappings, file permissions and ordering
using isolated HOME and fake process owners. Use live=False wherever supported.
Read generated values/contracts, not copy an old stylesheet/template body as new
implementation. Current tests identify GTK/Kitty/inverse contrast/rotation/cache/
prepared validation behavior; distinguish fixture origin from production source.
No private wallpaper, host/account/vault state copied into source/fixtures.

## Behavior to preserve

One serialized publisher, staged/atomic files, validated prepared data before any
commit, compatible rollback/fallback and synchronized poster-plus-color record.
Selection must retain per-wallpaper choice, fixed palette behavior and rotation
deadline semantics; no reset on unchanged wallpaper/renderer reload. Keep actual
source colors and current Natural default/optional Harmony, contrast at least 4.5
for intended text pairs, shared cursor preferences, current 0.98 terminal opacity
and private host/toolkit overrides. Audit the generated output contract for each
GTK/Qt, terminal, Hyprland, lock/login and branding consumer; helpers/generators
outside this file retain separate provenance scope.

Reuse valid prepared caches and avoid expensive repeated image/palette generation,
continuous polling or redundant native reloads. Own live commands use explicit
argument lists, scope failures clearly and preserve user apps/accounts. No changes
to full-access AI, package review policy, physical device/power settings or public
repo extraction. System applications/libraries with retained proper licenses stay.

## Acceptance

Isolated actual-owner tests for atomic writes/symlinks, malformed/stale prepared
payload refusal without partial publication, concurrency and producer/consumer
compatibility where existing coverage is insufficient. Existing behavior tests
must remain meaningful and pass. Native format/syntax/full tests/Hyprland and
reviewed plan/apply with drift/rollback required for runtime corrections. Compare
installed helpers/shell and live palette/settings/background coherence using an
owned preview or safe unchanged selection; never alter chosen wallpaper or persist
new preferences solely for QA. Private hashes and AI worker identity unchanged.
Exact-main CI; cold login/app restart/physical hardware limits explicit. Source
review must cover called dependencies separately before whole originality can be
claimed. Keep complete goal active until its full requirements are proven.
