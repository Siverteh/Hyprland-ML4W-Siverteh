# Knowledge helper current-source audit

2026-10-10 UTC. Six complete current helper bodies and two relevant test sources
reviewed against local creation/change history and private workflow contracts.

Context/usage first authored in 1bcce9d, vault utility in bcce02f, maintenance and
current three-way sync in adc96cc. Context, usage and maintenance parsed syntax
trees are unchanged from those bases despite formatting. Memory's changes remove
a registry-based subject restriction and an unused variable. Vault changes add
wiki/raw/checkpoints and updated labels; sync changes add retry classification,
backoff and desktop status. All current implementations are locally authored
workflow logic using standard native Python/filesystem/SSH/provider interfaces.

Complete current bodies were read before retention. This is source/history and
contract evidence, not a legal clean-room or final whole-upstream comparison.
Prior source exposure is acknowledged; no Caelestia/ML4W body consulted/copied for
writing replacements. No helper implementation changed in this audit. External
Codex/Claude APIs, Secret Service, SSH and Python retain their own licences.
Provider transport implementation and Brain application remain separate reviews.

Own fixtures use temporary homes/vaults and fake calls. They exercise conflict
preservation, no deletion propagation, input/path/symlink validation, backups,
restore-to-new-directory, offline backoff, context ambiguity, sanitized usage,
idempotent memory and preservation of curated aliases. This does not claim a
live remote exchange or secret-store test; none was run for this audit. Real
account/vault state, workers, provider permissions and update policy are untouched.

| Current artifact | Authoring basis | Later changes | Current SHA-256 |
|---|---|---|---|
| `bin/siverteh-ai-context` | `1bcce9d` | 83b3531 | `3a586e1772001266686b55104e92c798c8ace32e6639921e159bef96a4ef8870` |
| `bin/siverteh-ai-memory` | `1bcce9d` | bb46dd6, 83b3531, 543ee68 | `18dbabbf797025ab27d86f1e693a7a341fd3bf6c137bb3c8f9cf570d182499e1` |
| `bin/siverteh-ai-usage` | `1bcce9d` | 83b3531 | `852148a8762a3a1644c373f5bdfe65d5087d0cd63858d63c22a389637c06f165` |
| `bin/siverteh-brain` | `bcce02f` | 548f0b4, 83b3531, adc96cc | `991ffd72ae11ffadc612c2f764b59659cedc9fc3ed5e4e0e618abe0fcd63742c` |
| `bin/siverteh-brain-maintain` | `adc96cc` | 83b3531 | `623af7b76a2db344c3947db733a0bd0a7b57cbe29e104ae4befe069151e7d4ce` |
| `bin/siverteh-brain-sync` | `adc96cc` | 548f0b4, a5c973c, 83b3531 | `09c671149917de5fb10b7ff778c8000179e8580bdc9e71e89269de1bd114a785` |
| `ai/tests/test_conversation.py` | `1bcce9d` | bb46dd6, 83b3531, 543ee68 | `53a0af0f886ffcd95940b67873b1aca17c63cc9ccc5ab288aa352399ba841038` |
| `ai/tests/test_brain_sync.py` | `adc96cc` | a5c973c, 83b3531 | `e2851afbfae859307f2f276e84beb04b5a719086761af9008c481752b3d304d7` |

Validation: all 432 tests passed (72 tooling, 96 AI, 35 Brain, 229 shell),
with formatting/native QML/Lua/engine/JavaScript checks. Native Hyprland
verification and reviewed shell plan passed; config plan has 0 files/migrations.
Installed current/good UI/controller copies remain exact, services and native
frame/palette IPC healthy, no compositor errors. No runtime diff or redundant
apply/restart; real remote/secret-store interactions remain untested here.
