# Personal AI workspace

Workspace 2 opens ChatGPT and a Kitty controller. Use the controller to start
independent tasks, attach running sessions, open a project shell, or browse the
private brain. `SUPER+ALT+C` uses the existing daily workspace launcher.

## Prerequisites

This setup targets Linux x86_64 with Python 3.12 or newer (including
`hashlib.file_digest` and safe tar extraction filters), Git, OpenSSH, and Bash.
The desktop controller needs Kitty, fzf, ripgrep, jq, and flock; the desktop
launcher requires the installed ChatGPT app and Hyprland's Lua dispatch API.
Remote workers additionally require tmux and the complete pinned Codex package.
Credential commands require `secret-tool` (Arch's `libsecret` package) and a
configured, unlocked Secret Service provider. The installed KWallet provider can
be activated by the installer; wallet creation still requires the user.

Check these on the relevant host before installation:

```sh
python3 -c 'import sys, hashlib, tarfile; assert sys.version_info >= (3, 12); assert hasattr(hashlib, "file_digest") and hasattr(tarfile, "data_filter")'
command -v git ssh bash kitty fzf rg jq flock secret-tool
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
tmux, and an explicit Git worktree. Copy the `siverteh-ai-remote` and
`siverteh-brain` helpers and personal guidance to a trusted development host;
its own Codex credentials stay on that host. Run the installer with `--remote`
when installing a copy of this tooling there. It leaves the host's Codex binary
unchanged. Detach tmux with `Ctrl+B`, then `D`; the worker continues. Reopen it
through Running sessions. Clean up only finished, clean task worktrees.

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
the brain also synchronizes. The timer exchanges new Markdown notes every two
minutes; account files, keyring data, and Obsidian state are excluded. Common
credential patterns in complete notes are rejected before transfer.

Sync only creates absent note files. It never overwrites or deletes existing
notes. If the same filename has different content, both versions remain and the
command reports the conflict; inspect `journalctl --user -u siverteh-brain-sync`.
Reconcile edits deliberately or record a new dated note. This protects concurrent
writers but does not merge edits or replace a private backup.

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
