# AI bootstrap and support current-source audit

2026-10-10 UTC. All 23 scoped current file bodies were read and their local
creation/change history traced. These are locally authored integrations: account
isolation, remote task setup, installer ownership, skill exposure, app routing,
and declarative native service/configuration data. They are retained, rather than
rewritten merely because they share public Bash/Python/systemd interfaces.

Sixteen current bodies are unchanged from their local authoring basis (Python
compared by parsed syntax tree to ignore formatting). Seven evolved bodies were
reviewed through their full current implementation and change diffs: install.py,
account/remote wrappers, sync service/timer, app route and xdg-open wrapper.
The xdg-open routing body was completely replaced in 2fa3a95; its original
4ab59b0 wrapper had referenced the old ML4W browser setting. The current seven
lines use the independently maintained route and compositor helper. No retained
ML4W browser-setting implementation remains in this wrapper.

This is source/history/interface evidence, not a legal clean-room assertion or
final whole-upstream similarity comparison. Prior source exposure is acknowledged.
No Caelestia/ML4W implementation was consulted or copied for a replacement in
this audit; no runtime implementation changed. Existing notices remain pending
the complete tree assessment.

The pinned Codex, Claude SDK and Obsidian packages, KDE Secret Service and downloaded
specialist skills are external dependencies, not Nacre-authored software/art.
skill-sources.json only describes pinned sources; the skill installer retains
upstream root licence files when installing them outside this repository.
Their own licences still apply. No package/skill download, login, authentication
copy, remote connection, wallet replacement or live AI installer was run for QA.
Personal AI naming/state paths are compatibility interfaces, not desktop branding;
renaming those would be a separate state migration and is unnecessary here.

| Current artifact | Local authoring basis | Later changes | Disposition | Current SHA-256 |
|---|---|---|---|---|
| `ai/configure-remote-shell.py` | `bcce02f` | 83b3531 | independent | `c379af5d9d78b912fc9042bf73aa305e3f4b69373142db487bf723adc5ed6b95` |
| `ai/dbus/org.freedesktop.secrets.service` | `bcce02f` | none | non-implementation | `cb5122d2aadb8fc7e1360f7bad83a941579c637083a3c7d9502526d11ac1ef69` |
| `ai/fix-fish-presentation.py` | `b4f2ddb` | 83b3531 | independent | `743c4424091f9aced111aae271fa3fb803892166d07fec222dde389be20c961b` |
| `ai/install-claude.py` | `4c2ae49` | 83b3531 | independent | `80817c502e4639ddaec7484f69604860f5181414a87b79f19c968272405bc8ed` |
| `ai/install-codex.py` | `bcce02f` | 83b3531 | independent | `b6ce9d94bf5d4e2fa2bd329857489ecf6e09bb08b29e5ef856588ecb7141822e` |
| `ai/install-obsidian.py` | `bcce02f` | 83b3531 | independent | `52357e8d8b1dfe25b654ad79142eaba71104eb0ef7a7fb8bbf66a9b3bd4e4305` |
| `ai/install.py` | `bcce02f` | 548f0b4, 7bdf0e7, 83b3531, 1bcce9d, adc96cc, fc33e68, 4c2ae49 | independent | `5f14c1d6b9732389b449ef8b2f0b2ccbdd6219eeb01e229c21cebcb2dc598a74` |
| `ai/projects.example.json` | `bcce02f` | none | non-implementation | `83219fa3585b49e192670a5e85c315444bd944e6220f657bcd2e177478f7f562` |
| `ai/remote-codex-wrapper.sh` | `bcce02f` | none | independent | `37d1811c4a76d1faa1f6e4a97e2bb37e80961067b4c90d7dd81b4142be9378c8` |
| `ai/skill-sources.json` | `fc33e68` | none | non-implementation | `66f050d15d93ace9cd7c6b38da2ce090bfb4f8e6c8768a7393d455ddf4212148` |
| `ai/systemd/siverteh-brain-check.service` | `adc96cc` | none | non-implementation | `31d1db659b061d6ddb580e96f88c8d385e9b68d981bdd58b96bd7f65c2d9dda7` |
| `ai/systemd/siverteh-brain-check.timer` | `adc96cc` | none | non-implementation | `85a35eb517e74f65c4c7539d33c35d3041a1cd2d4aded407d84a9b86436569dd` |
| `ai/systemd/siverteh-brain-sync.service` | `bcce02f` | a5c973c, adc96cc | non-implementation | `faab8451427a98f54200eee51e0cbbdee5d649fdfd55a9edaa9a8f1dd10de22c` |
| `ai/systemd/siverteh-brain-sync.timer` | `bcce02f` | adc96cc | non-implementation | `0d8ecf151410671daf7b68b6fab756cf7f665712da656cffb1dfec0143e30950` |
| `bin/codex` | `bcce02f` | none | independent | `7f4d9ad01e8fe43f7bfdc70debffcd7367abd7d0ab5cc752e10b1dde23066f5e` |
| `bin/nacre-app` | `2fa3a95` | 548f0b4, a046f7b, 86bebe6, 83b3531 | independent | `630c7ca01630f4e043e1ee601fc0c31bcbf8f98eafbe964e77d652ee0794a857` |
| `bin/obsidian` | `bcce02f` | none | independent | `149e0565d292f49b458af0cd4d233efde85be8ed2985cb0b0be11b8c57f0a0f7` |
| `bin/siverteh-ai-account` | `bcce02f` | 83b3531, fc33e68, 4c2ae49 | independent | `04456392e1ee2ee185ce68452c13535f2486a7466ac8d1ba10290eb5ca9a6f68` |
| `bin/siverteh-ai-remote` | `bcce02f` | 4c2ae49 | independent | `e7218e1a7053f8556ea12d27540f15bc7317262f8efe6f564da5479c0df83f8c` |
| `bin/siverteh-ai-skills` | `fc33e68` | 83b3531 | independent | `d9bbd8c53123afaf24f318a1260c7e6a8f8c5ed0d17187233c808b7e240f7884` |
| `bin/siverteh-ai-tools` | `fc33e68` | 83b3531 | independent | `f35bd6e1c3fe9912f0a7ede14db00db10ad142387dd39aea08349c3ba3cd6eca` |
| `bin/siverteh-os-app` | `548f0b4` | none | independent | `a2be8b075584b17b5fe0bcfb16dce4a5cf81d81cd94d976b4d7f7bdcbdeb674f` |
| `bin/xdg-open` | `2fa3a95` | 548f0b4 | independent | `69be5a8d2dbc1acaac43447d47155a4773b37c2f14420693a5b5ad9e3a5d9c78` |

Validation: all 432 tests passed (72 tooling, 96 AI, 35 Brain, 229 shell),
including isolated account/install/skill/Obsidian fixtures. Python formatting,
Lua syntax, native QML parsing, palette CLI and Brain JavaScript checks passed.
Native Hyprland verification passed. Reviewed shell plan; config plan reports
0 files and 0 migrations. No runtime diff, so no redundant live apply/restart.
Installed current/good shell and three release-controller files are byte-exact;
frame/palette IPC responds, shell/sidebar/Hypridle active, config errors empty.
Initial obsolete-service/unsupported-status queries were corrected; they made
no changes. Full upstream comparison and physical cold-login checks remain open.
