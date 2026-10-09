# Update provider and Qt guard provenance audit

Spec ready, 2026-10-09. Next bounded area: services/Updates.qml and
shell-tools/{updates.py,updates.sh,qt-check.sh}, plus their maintained tests.
These are candidates for locally authored feature code, not presumed inherited
because they live alongside earlier adapted shell modules.

## Origin evidence

Follow renames and any copy/consolidation ancestry to initial authoring, including
7a05033 (shared update owner), 2fa3a95 (desktop maintenance commands), ac8be46
(readable update failures and shared Qt guard), 0fb1f9f/6f88e53/0f3bd08 (recovery
build detection and revision compatibility), and 548f0b4 (namespace migration).
A new-path commit alone is insufficient proof; investigate predecessor inputs.
Record exact current-file evidence and caller/producer dependencies. Keep an
honest distinction between local history, inherited portions and unresolved origin.
Do not consult upstream implementation bodies while writing replacements.

## Behavior contracts

One shell-wide update owner, not one per output. Retain count/status/message,
refresh cadence, check serialization, failure handling and all existing callers.
Check package updates without performing them during tests or live acceptance.
Recovery Quickshell build detection must distinguish incompatible Qt versions
from harmless distribution package revisions and identify a supported switch back.
Updates keep paru --skipreview and readable failed-step/exit-code output before
waiting for Enter. The same compatibility guard serves launch and update paths.
Never change full-access AI policy, package installations or private state merely
as part of this source audit.

## Review or replace

Retain verified locally authored implementations with SHA-bound history/spec
records. If inherited behavior is found, capture public contracts, delete the
inherited body, then independently implement from this spec/platform APIs/tests.
Extend tests only to resolve meaningful unverified behavior. A low similarity
score or changed name alone does not prove independence. Dependencies and fixtures
receive their own dispositions; no blanket certification of the helper tree.

## Acceptance

Trace source origin and interfaces; run relevant isolated update/compatibility
tests and full tools/check.py, native Hyprland verification and registry integrity.
Deploy changed runtime code only after a reviewed plan, then verify exact installed
source, actual update provider/IPC and no competing owner or private worker restart.
For documentation-only audit, retain the already verified active runtime and
compare bytes instead of needless cutover. Exact-main CI before finishing.
No real package update, forced logout or fabricated cold-start/hardware proof.
Retain notices and keep the full originality goal active pending whole-tree review.
