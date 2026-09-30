---
name: siverteh-project-work
description: Start or resume an independent local or SSH project task in Siverteh's terminal workflow, preserving parallel sessions and project-specific instructions.
---

# Siverteh Project Work

Read `$HOME/.config/siverteh-ai/projects.json` for this machine's project registry.
Use `siverteh-ai projects` for an overview and `siverteh-ai new --project ID` for
a terminal worker. `siverteh-ai sessions --project ID` reopens a local Codex
dashboard or a running remote tmux session. The GUI dashboard opens workers in
separate Kitty windows, keeping the controller available.

Each new writing task starts in its own worktree. Do not move another task's
branch or reset shared changes. Read the project's AGENTS.md and relevant SPEC
before editing, then run the smallest proof named there. Save a concise handoff
to the private brain when it contributes reusable knowledge.

Remote tasks use the host's existing Codex executable and credentials. Do not
upgrade, migrate, or log out another running Codex client as part of launching
a task. tmux keeps workers alive when SSH disconnects. New remote worktrees are
under `$HOME/.local/share/siverteh-ai/worktrees`; remove only clean, idle ones after
the project has finished using them.

`siverteh-ai --account NAME login` creates a separate local Codex home. Login
still requires the user's own authentication. Never interpret a Codex config
profile as an account or copy auth.json to imitate switching accounts.
