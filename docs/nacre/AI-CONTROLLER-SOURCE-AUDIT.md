# AI controller current-source audit

2026-10-10 UTC. Complete current launcher (1,359 lines), Codex transport
(587 lines) and Claude adapter (293 lines after correction) read, with local
creation/change histories and native/account/project caller contracts traced.
All three are locally authored workflow integrations, retained independently of
the inherited desktop UI. The full-access correction does not certify the rest
of a file by itself: current bodies were reviewed separately.

The launcher combines account selection, temporary chat/worktree routing, native
history and terminal menu behavior. Codex transport implements a local bounded
stdio request loop and MCP wrapper using the provider's public protocol; Claude
adapter uses the external SDK for history and the installed CLI for sessions.
Their external providers/native tools remain separately licensed dependencies,
not bundled Nacre implementation. Initial local bases are bcce02f/4c2ae49;
subsequent account/context/menu/startup and branding changes were traced. Parsed
function comparison is supporting evidence only, not a provenance certificate.
Prior source exposure is acknowledged. This is not a legal clean-room claim or
the final whole-upstream comparison; applicable notices remain.

Found an existing policy inconsistency: terminal Claude adapter omitted the
skip-permissions flag used by the sidebar and promised in the user policy.
New fake-launcher regression fails both new/resume baseline paths, then passes
0f31dd9; selected account and resumed session identity are checked. The adapter
now explicitly includes the flag. No global configuration or running worker
permissions changed. [Anthropic CLI reference](https://code.claude.com/docs/en/cli-reference)
documents this native flag.

The AI installer now extends its recognized-runtime atomic launcher update to
three explicit controller names via --helper-only. Existing --launcher-only is
compatible; no account/skill/vault setup executes in that branch. A temporary
runtime fixture verifies plan/apply, backup, mode/symlink, private state and peer
preservation, and rejection of unrelated names. Installer current full body was
previously read and its new branch/diff reviewed here; its registry hash is
explicitly superseded. ai/README.md corrects the contradictory permission sentence
and documents this code-only operation. Other documentation audit remains open.

| Current artifact | Local basis | Later changes | Current SHA-256 |
|---|---|---|---|
| `bin/siverteh-ai` | `bcce02f` | 548f0b4, 7bdf0e7, 83b3531, 2fa3a95, b0632b9, 3121dad, be81bf0, 1bcce9d, e42b701, 4c2ae49 | `60c59938858b77b8222d701676bbbad27af9c91db1b601a61597dd828f0df7f0` |
| `bin/siverteh-ai-chat` | `4c2ae49` | 548f0b4, 83b3531, be81bf0, 1bcce9d | `70f51b3d5a23b3dbb6f19ba93798ac8c9965d6ef87c067a52237dce7c4eb996e` |
| `bin/siverteh-ai-claude` | `4c2ae49` | 0f31dd9, 548f0b4, 83b3531, 1bcce9d, fc33e68 | `a1395acac130f04a79bd22bde0de98d5f280efbb6bdd8d20c92a6d8f9f9b8086` |
| `ai/install.py` | `bcce02f` | 0f31dd9, 548f0b4, 7bdf0e7, 83b3531, 1bcce9d, adc96cc, fc33e68, 4c2ae49 | `956986b66bfdc288fed4c49433b65c4a79e05df287bccea847fb290ec9743a06` |
| `ai/tests/test_claude_workflow.py` | `4c2ae49` | 0f31dd9, bb46dd6, 83b3531, 1bcce9d | `f9e66af6449296a81ee8ad5d5f387ae26cd307223ea5f12d76b12a6235e7b56a` |
| `ai/tests/test_codex_startup.py` | `7bdf0e7` | 0f31dd9 | `80357cbe34b2ee2df6ba7c6ec1795977dabcbec34376d53d7d3866ad52f1bb5b` |

Validation and deployment: 434 tests passed (72 tools, 98 AI, 35 Brain, 229 shell),
with Ruff/native QML/Lua/engine/JavaScript checks and native Hyprland verification.
First full gate stopped on a plan-message formatting violation; separate fce6b74
formatting commit has an identical parsed syntax tree and rerun passes. Config
plan has zero files/migrations. Three recognized code-only controller plans were
reviewed and applied, each with a dated private backup. Installed Claude had the
exact parsed body of 1bcce9d; other old copies differed only in branding from the
reviewed current bodies. An initial comparison against an incorrect literal SHA
was replaced with actual Git-source hashes and normalized body comparisons.
All three installed controllers now match the candidate bytes, symlinks intact.
Running sidebar backend PID/start time unchanged; current/good UI source exact,
services and frame/palette IPC healthy, no compositor errors. No real provider
inference, login, auth copy, daemon restart, vault sync or shell restart for QA.
