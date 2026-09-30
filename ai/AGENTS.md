# Personal workflow

Use the private vault at `$HOME/Documents/Siverteh-Brain` for durable personal
preferences, dated host/device facts, project pointers, and operational lessons.
Search only the relevant notes (`siverteh-brain search WORDS`) before relying on
past context. Repository AGENTS.md, SPEC files, and live evidence remain the
authority for project behavior; this vault is a cross-project index.

After meaningful work, save newly verified reusable knowledge with
`siverteh-brain note --kind KIND --title TITLE --source SOURCE --confidence verified`
and a concise Markdown body on stdin. Include the date, evidence, exact scope,
and remaining uncertainty. User-reported facts use `reported`; historical
assumptions use `unverified`. Search first and avoid duplicate summaries. Unique
note files let parallel chats record facts without overwriting each other.

The vault is private and separate from the public OS repository. Never put its
personal notes, infrastructure inventory, conversations, or account state in
public Git. Passwords, tokens, and private keys belong in the OS secret store;
notes contain only references such as `secret-service://siverteh-brain/NAME`.
Do not print secrets into transcripts, command arguments, or logs. Do not copy
Codex authentication between accounts. Account profiles share guidance and the
vault, while authentication and conversations remain separate.

Use one Git worktree per independent writing task. Preserve pre-existing edits
and active sessions. Remote workers run in tmux so disconnecting the laptop
does not stop them. Record handoff evidence and clean up only clean, idle task
worktrees once no more edits are needed. Follow each project's own workflow.
