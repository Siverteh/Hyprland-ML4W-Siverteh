# Personal AI workspace

Workspace 2 opens ChatGPT and a Kitty controller. Use the controller to start
independent tasks, resume running sessions, or optionally browse private notes.
Obsidian is never launched by the workspace launcher; agents use the Markdown
files directly even while it is closed. `SUPER+ALT+C` uses the existing daily workspace launcher.

## Daily use

The dashboard has eight actions: **New task**, **Resume latest task**, **Load task**,
**New project**, **Project terminal**,
**Open brain**, **Settings**, and **Close**. A responsive alternate-screen menu
keeps one logo and one selection list visible, including during window resizing.
Every submenu includes Back; Escape also returns and stays in the main menu. Close exits only the
dashboard, leaving workers running. Project terminal remains a separate command
prompt; `exit` or Ctrl+D closes it.

New project creates a named local folder under `~/Projects`, initializes Git, and
registers it without overwriting folders or making an initial commit. It offers
Start task or Back. New task offers **General chat** first, followed by registered
projects. General chat needs no repository and uses a private scratch folder per
conversation under `~/.local/share/siverteh-ai/chats`; it appears in Load task and
Resume latest task for the current account. Ask ordinary questions, or ask to work
on a named project later in the same conversation. The agent reads the project
registry and its instructions, uses explicit working directories, and creates an
isolated worktree before editing. The installed Codex user default is full filesystem and network access, with command
approval prompts disabled; project instructions and user-requested scope still apply.
Its history stays grouped under General chat even if a project is discussed later.

Choosing a project in New task then offers **Codex** or **Claude Code**. Both use an
isolated worktree; an empty repository uses an orphan worktree until its first
commit. Remote workers run in tmux; detach
with Ctrl+B, then D. Resume latest task opens the most recently updated chat
across configured projects for the selected account, without another picker.
Load task combines native Codex and Claude Code chats across those projects, newest first, with assistant labels, project names and
running/saved status. It attaches running remote tasks or resumes the exact saved
thread; local tasks resume in their recorded working directory. If no chats exist,
it returns without starting a new task. Each chat resumes in its original assistant; this does not convert or merge transcripts between assistants. Load task retains available histories with a warning when a source is unavailable.
Resume latest reports an error rather than silently choosing a different latest task.
New agents are instructed to assign a concise title through the local
`siverteh_workflow.set_chat_title` MCP tool. It only exposes chat naming via
Codex’s supported API; it does not grant additional permissions itself.
Titles use the native `thread/name/set` API, not direct database edits. An unnamed
chat displays its first-request preview until the agent gives it a title. Separate
account homes stay separate. Local resume uses the native Codex resume interface.

Agents automatically checkpoint useful verified findings and preferences into the
private brain at milestones and before handoff. This is agent behavior guided by
shared instructions, not an indiscriminate conversation recorder. Trivial turns,
duplicate facts and secrets are excluded. The existing two-minute file sync moves
new notes between configured hosts; Obsidian need not run. New/resumed sessions
load updated guidance; already-running sessions may retain earlier instructions.

Terminal workers and ChatGPT app projects have separate conversations. Their
shared knowledge is the private Markdown vault, not a unified chat history.

## Claude Code

Install the native Claude Code CLI using [Anthropic's setup instructions](https://code.claude.com/docs/en/setup).
Run `python3 ai/install-claude.py` for the isolated, pinned Python session-history
SDK, and `python3 ai/install.py` to link the adapter. Install these on each host
where Claude tasks run. Sign in with `siverteh-ai login --agent claude` (or
`claude auth login`). Claude authentication is independent of Codex.

`New task → project/General chat → Claude Code` starts a native interactive Claude
session. CLI callers use `siverteh-ai new --project PROJECT --agent claude`.
Project tasks get separate `claude/…` worktrees; general chats use independent
scratch folders. Remote tasks run in tmux. The adapter passes shared brain and
project instructions through Claude's supported appended system prompt, including
reading repository AGENTS.md and respecting remote build-host settings. Native
Claude configuration and permission modes remain in effect.

The combined history uses Codex's supported thread API and Anthropic's
`list_sessions()` metadata API, with millisecond timestamps normalized before
sorting. Titles come from each assistant's native history; Claude's `/rename`
updates the displayed title. This does not parse or rewrite private transcript
formats. `--account NAME` keeps Claude data in a separate
`~/.local/share/siverteh-ai/claude-accounts/NAME`; it never copies Codex credentials.
No Claude login or SDK is needed to list a host/account with no Claude history.

## Accounts in Settings

Settings provides Accounts, Default assistant (Ask each time, Codex or Claude Code),
and Check setup (installed tools, selected-account login status, and shared brain).
It does not show authentication tokens or change running sessions.

Accounts shows the selected Codex and Claude Code accounts independently. Select
an existing profile to use it for new tasks and that assistant's history, or
choose Add account, enter a short label, and complete the assistant's own sign-in
in a separate terminal/browser. Successful sign-in activates only that assistant's
new profile; cancellation leaves the previous selection in place. Sign in to
selected account reauthenticates that profile. Every submenu has Back.

Account selection is stored privately in `~/.config/siverteh-ai/settings.json`.
Default uses the existing native account; named profiles use separate provider
homes. Switching never logs out or changes running chats. History is combined
across the two selected accounts, not across every account's private history.
Rows identify project, assistant, account, and state. Explicit `--account NAME`
overrides the saved selection for that invocation. Remote hosts authenticate
independently under the same profile name; no credentials are copied over SSH.

## Access defaults

New and resumed Codex workflow tasks use `--sandbox danger-full-access
--ask-for-approval never`. Installation and account setup write matching
`sandbox_mode` and `approval_policy` defaults into that account's Codex config,
so ordinary Codex launches use the same access. Existing running sessions keep
their current permission settings until reopened. Explicit CLI/profile overrides
and centrally managed restrictions can still take precedence. Authentication,
OS account permissions and SSH authorization are unchanged.

## Prerequisites

This setup targets Linux x86_64 with Python 3.12 or newer (including
`hashlib.file_digest` and safe tar extraction filters), Git, OpenSSH, and Bash.
The desktop controller needs Kitty, Python curses, ripgrep, jq, and flock; the desktop
launcher requires the installed ChatGPT app and Hyprland's Lua dispatch API.
Remote workers additionally require tmux and the complete pinned Codex package.
Credential commands require `secret-tool` (Arch's `libsecret` package) and a
configured, unlocked Secret Service provider. The installed KWallet provider can
be activated by the installer; wallet creation still requires the user.

Check these on the relevant host before installation:

```sh
python3 -c 'import sys, hashlib, tarfile; assert sys.version_info >= (3, 12); assert hasattr(hashlib, "file_digest") and hasattr(tarfile, "data_filter")'
command -v git ssh bash kitty rg jq flock secret-tool
# On the remote worker host:
command -v git bash tmux
```

The wallpaper repair separately requires Waypaper with native awww support and
the awww renderer. The install helpers do not install general system packages;
the existing CachyOS desktop was validated separately.

## Installation

Run `python3 ai/install-codex.py`, then `python3 ai/install.py` from the installed OS checkout. It links user-level
tools and personal skills, preserves replaced files in a dated backup, and
creates the private vault. The terminal `codex` wrapper uses the complete official
CLI package pinned to 0.159.2, including its daemon manifest and companion tools.
It does not replace or upgrade the ChatGPT app or an older system Codex install.

Configure projects in `~/.config/siverteh-ai/projects.json` using
[projects.example.json](projects.example.json). Keep real hosts, paths, account
details, and project registries outside this public repository.

```sh
siverteh-ai                         # controller menu
siverteh-ai new --project PROJECT   # isolated writing task
siverteh-ai sessions --project PROJECT
siverteh-ai shell --project PROJECT
siverteh-ai brain
siverteh-ai login --account second  # authenticate independently
siverteh-ai new --project PROJECT --account second
siverteh-ai login --project REMOTE_PROJECT --account second
siverteh-ai new --project REMOTE_PROJECT --account second
```

Local sessions use `codex agents` and `codex --worktree`. Remote workers use SSH,
tmux, and an explicit Git worktree. New Codex workers explicitly select danger-full-access with approval prompts
disabled. Claude retains its native permission settings.
SSH children advertise the widely available `xterm-256color` terminal type;
the desktop retains its own terminal setting. Copy the `siverteh-ai-remote` and
`siverteh-brain` helpers and personal guidance to a trusted development host;
its own Codex credentials stay on that host. Run the installer with `--remote`
when installing a copy of this tooling there. It leaves the host's Codex binary
unchanged. Detach tmux with `Ctrl+B`, then `D`; the worker continues. Reopen it
through Resume task. Clean up only finished, clean task worktrees.

Each `--account NAME` uses a separate directory under
`~/.local/share/siverteh-ai/accounts/`. Authentication and conversations are
separate; the private vault and user skills are shared. The default profile
continues to use the configured host account. A configuration profile is not
an account. Do not copy credentials between different accounts. Remote account
profiles live separately on the remote host and use normal device login when you
add an account. The shared vault and guidance are the only common data.

## Private knowledge

`python3 ai/install-obsidian.py` installs the official checksum-pinned Linux x64
Obsidian AppImage for this user without sudo. Run it from the installed OS checkout.

`~/Documents/Siverteh-Brain` is a normal Markdown folder. Open it as an Obsidian
vault; Codex can also search it without Obsidian. New notes have unique names,
source evidence, confidence, and timestamps. Existing project instructions and
SPEC files remain canonical; save concise pointers and operational lessons.

```sh
siverteh-brain search 'topic'
siverteh-brain note --kind decisions --title 'Decision title' \
  --source 'Evidence location' --confidence verified < note.md
siverteh-brain store-credential credential-name
siverteh-brain run-with-credential --env SERVICE_KEY credential-name -- command
```

Credentials use the OS Secret Service. On this KDE-equipped Hyprland setup the
installer makes the installed KWallet provider activatable if no provider is
configured. The first credential store may open the wallet setup/unlock dialog;
choose an encrypted, password-protected wallet. No wallet password is invented,
and credentials cannot be stored until that setup is complete.

Notes contain references, never passwords,
tokens, or private keys. `run-with-credential` supplies a secret directly to a
child's environment; that child is responsible for not logging it. The note
filter catches common accidental credential formats but is not a complete secret
scanner. The vault is private local data and is not a backup.
Do not commit it, Codex homes, account state, or project registries to this public
repository.

For private note sync, install the helpers on both hosts and create
`~/.config/siverteh-ai/brain-sync.json` with `{"host": "my-server"}` (mode `0600`).
The selected SSH alias must be trusted and use key authentication. Both ends use
their own `~/Documents/Siverteh-Brain`. Run `siverteh-brain-sync`, then enable
`systemctl --user enable --now siverteh-brain-sync.timer` on the desktop. Opening
the brain also synchronizes. The timer synchronizes managed Markdown/text/Bases/Canvas files every two
minutes. Account files, keyring data and Obsidian UI state are excluded. Common
credential patterns are rejected before transfer. Protocol 2 accepts one-sided
edits relative to the last common version; divergent edits are preserved and
reported. It never propagates deletions. See Versioned private knowledge below.

Ordinary ChatGPT web memory does not read this folder. Codex's generated local
memories are a separate optional recall system; the Markdown vault is the
maintainable, account-independent source you control. New conversations pick up
new global instructions and skills; existing running conversations keep their
current context.

When installing a pinned executable, copy it to a temporary filename first,
wait for the transfer and checksum verification, then rename it atomically.
Do not execute a file while it is still being transferred.

## Existing desktop repairs

If SSH prints the desktop logo, `python3 ai/fix-fish-presentation.py` wraps only
the known Fastfetch block in `status is-interactive`, after preserving a backup
and checking Fish syntax. It leaves PATH and other noninteractive setup active.

For a development host with an older active Codex client, `remote-codex-wrapper.sh`
selects the separately installed, pinned CLI and private home. It explicitly
protects the older `~/.codex` home, including when that path is inherited in
`CODEX_HOME`; separate named-account homes remain supported. Use the complete
package installer on that host; copying just the CLI binary cannot start its daemon.
Prove login, an interactive session, and a read-only
task before putting the wrapper on PATH. `configure-remote-shell.py` moves an
existing user-bin PATH line before Bash's noninteractive return and backs it up.
Rollback restores that Bash file and removes only the new wrapper; the previous
CLI and its state remain intact.

## Sources checked 2026-09-30

- [OpenAI Linux desktop support](https://learn.chatgpt.com/docs/linux/linux-app):
  the preview now includes Arch. CachyOS is not separately listed; native
  Wayland remains experimental and Linux Computer Use is not yet supported.
- [Desktop SSH projects](https://learn.chatgpt.com/docs/remote-connections#connect-to-an-ssh-host):
  the remote login shell must resolve an authenticated Codex executable. Keep
  SSH version/authentication testing separate from active older clients.
- [AGENTS guidance](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
  and [skill discovery](https://learn.chatgpt.com/docs/build-skills): keep global
  guidance short; personal symlinked skill folders are supported.
- [Local memories](https://learn.chatgpt.com/docs/customization/memories):
  generated local Codex state differs from web memory. Current documentation
  does not establish the old claim that Norway is excluded.
- [Obsidian storage](https://obsidian.md/help/data-storage): local Markdown files
  remain readable by other editors; external edits refresh in Obsidian.

## Validation

Run `python3 -m unittest discover -s ai/tests -v` and shell syntax checks for
`bin/codex`, `bin/siverteh-ai-remote`, and `hypr/scripts/ai-workspace.sh`. Desktop
verification should launch the workspace twice, confirm one controller and one
ChatGPT app, open a local worker, detach/reopen a remote worker, and confirm the
private vault is available. Never include private evidence in the public diff.

Projects can keep their primary checkout local and declare `build_host` and
`build_path` for heavy remote builds/tests. Agents read this registry at startup,
then follow project instructions and use isolated remote worktrees with the exact
task changes. This is an agent workflow, not transparent compiler offloading.
Optional `task_sources` entries retain named chat history on former task hosts;
new tasks use the primary path and resumed chats retain their original host.


## Shared specialist skills

Run `python3 ai/install.py`, then `siverteh-ai-skills --install` to fetch the
revision-pinned sources in `ai/skill-sources.json`. Ten selected skills cover
Obsidian Markdown/Bases/Canvas, webpage extraction, frontend design, document
coauthoring and PDF/Word/PowerPoint/Excel. Source licenses are retained. No
upstream scripts execute during installation. Existing conflicting skills are
preserved and reported, never silently replaced.

The library is exposed to both assistants and existing named accounts; new
account launches link it automatically. Authentication is never shared. Skills
become available in fresh sessions. Optional document/rendering tools may require
an isolated dependency installation for the requested operation.

Brain maintenance and project checkpoints extend the two existing personal
skills. Agents save evidence-based milestones, superseding links and concise
handoffs through the private brain helper. This is agent-driven, not a background
summarizer; it never copies entire chat histories or requires Obsidian to be open.

Use `siverteh-ai-tools python`, `siverteh-ai-tools node`, or
`siverteh-ai-tools defuddle` for installed isolated document/extraction tools.
Their environment is `~/.local/share/siverteh-ai/skill-tools`; it does not replace
project Python/Node environments. Some upstream document skills assume hosted
preinstalled tools: use this wrapper here. LibreOffice/Pandoc must be checked
separately before conversions; never claim rendering or formula recalculation
was verified if those tools were unavailable.

Tool dependencies can be rebuilt without changing project environments:

```sh
python3 -m venv ~/.local/share/siverteh-ai/skill-tools/python
~/.local/share/siverteh-ai/skill-tools/python/bin/pip install pypdf pdfplumber reportlab python-docx openpyxl pandas 'markitdown[docx,pptx,xlsx]' Pillow defusedxml lxml pyyaml
npm install --prefix ~/.local/share/siverteh-ai/skill-tools defuddle docx pptxgenjs react-icons react react-dom sharp
```

A host needs Node available in PATH or at `skill-tools/node/bin`. The personal
computer uses an isolated official Node distribution with its SHA256 checked
against nodejs.org. npm records the installed tree in package-lock.json in the
tool directory; Python versions can be inspected with the environment's pip.


## Versioned private knowledge

The evidence folders remain append-only. `wiki/` contains maintained synthesis;
`raw/` contains text source extracts; `checkpoints/` contains task handoffs.
Read INDEX.md first. Wiki pages include Reviewed, Status and source links.

Sync protocol 2 uses the last common per-peer content to accept one-sided edits.
Divergent edits remain on each host and both copies are saved as conflict evidence.
No deletions propagate. Both hosts must be upgraded together. All helper writes
use an advisory vault lock; use the read/update compare-and-swap helper for wiki
edits. Direct editor writes do not participate in that lock.

Snapshots are checksummed JSON with private permissions in .brain-state/backups.
They cover managed .md/.txt/.base/.canvas files and root policy/index files only.
They are created before/after synchronization and page updates, and daily by the
health timer. Restore always uses a new directory. No automatic snapshot pruning
is enabled. Private notes/snapshots are never placed in the public OS repo.

```sh
siverteh-brain-maintain check
siverteh-brain-maintain backup
siverteh-brain-maintain read wiki/project.md
siverteh-brain-maintain update wiki/project.md --expected-sha256 HASH < revised.md
siverteh-brain-maintain restore /path/to/snapshot.json /new/private/restore-folder
```

Enable `siverteh-brain-check.timer` and `siverteh-brain-sync.timer` with systemctl
--user after install. Check results appear in the user journal; a failed check
makes the service fail visibly. This timer does not invoke models or rewrite notes.
Factual reconciliation remains the agents' responsibility.
