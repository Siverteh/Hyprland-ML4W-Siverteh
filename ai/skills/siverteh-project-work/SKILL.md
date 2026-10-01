---
name: siverteh-project-work
description: Start or resume an independent local or SSH project task in Siverteh's terminal workflow, preserving parallel sessions and project-specific instructions.
---

# Siverteh Project Work

Read `$HOME/.config/siverteh-ai/projects.json` for this machine's project registry.
Use `siverteh-ai projects` for an overview and `siverteh-ai new --project ID` for
a terminal worker. `siverteh-ai sessions --project ID` reopens a local Codex
dashboard or a running remote tmux session. The GUI dashboard opens workers in
separate Kitty windows, keeping the controller available. Choose New task, then a project (or General chat), then Codex or Claude Code. Resume latest
task immediately returns to the most recently updated chat across configured
projects and both assistants. Load task labels each chat Codex or Claude Code; resume it in its original assistant, not a converted conversation. Escape goes back within menus; Close dashboard exits
only the controller. Project terminal is for manual commands, not AI chat;
`exit` or Ctrl+D closes that separate window. Obsidian is optional and is not
started by the workspace launcher.

General chat in New task starts without a project. Resolve projects later from
the registry when the user asks; read the chosen project's instructions, use
explicit working directories and an isolated worktree for changes. Keep the same
conversation. Full access is the configured user default; keep changes scoped
to the request and preserve other tasks.
Do not create or modify a project for a question that only asks for explanation.
General chats remain grouped under General chat in history.

New project creates a local repository under ~/Projects and registers it; New
task uses an existing project. Menus provide Back as well as Escape.

Projects may declare build_host and build_path. These designate a remote build
machine while the project path remains the local editing checkout. For heavy
builds/tests, use SSH and an isolated remote worktree containing the exact task
revision and changes; use tmux for long runs and bring artifacts/results back.
Never build an unrelated stale remote checkout or overwrite another task.
Task sources preserve access to chats started on another host; resuming those
chats stays on their original host, while new tasks use the primary project path.

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

Name new chats automatically once the request is understood:
the `siverteh_workflow.set_chat_title` MCP tool, with `CODEX_THREAD_ID` from
your shell. This changes the native Codex name shown in Resume. Save durable findings
to the brain at milestones and before final handoff without asking the user to
remind you. Obsidian need not be open.

Claude Code shares the project registry and brain guidance but has its own login
and native permissions. Use siverteh-ai login --agent claude to authenticate.
Named Claude profiles use separate CLAUDE_CONFIG_DIR homes, never Codex auth.
The launcher appends guidance to read repository AGENTS.md alongside CLAUDE.md.
For Claude titles, use native session names or /rename; do not call the Codex
set_chat_title tool for a Claude session.

Settings provides independent Codex/Claude account selectors, named sign-ins,
a default assistant choice, and a setup status check. Load task combines only the
selected accounts' histories and labels assistant/account. Switching accounts
does not alter running sessions. Both assistants use the same private brain.

## Durable task checkpoints

Use [the handoff guide](references/handoff.md) for significant multi-step work,
at milestones and before ending unfinished work. On resume, retrieve the latest
relevant checkpoint and verify its state before continuing. Do not generate
checkpoints for trivial questions or duplicate an unchanged one.
