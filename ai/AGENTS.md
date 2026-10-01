# Personal workflow

Use the private vault at `$HOME/Documents/Siverteh-Brain` for durable personal
preferences, dated host/device facts, project pointers, and operational lessons.
Search only the relevant notes (`siverteh-brain search WORDS`) before relying on
past context. Repository AGENTS.md, SPEC files, and live evidence remain the
authority for project behavior; this vault is a cross-project index.

Keep the brain current automatically; do not wait for the user to request it.
At meaningful milestones, after learning a durable fact or preference, and before
finishing or handing off, save new reusable knowledge. During long tasks, do this
as findings are verified rather than deferring everything to the final response.
Skip trivial turns, duplicate facts, transient logs and speculation. Corrections
should explicitly supersede the earlier dated fact with new evidence.

Save newly verified reusable knowledge with
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

At the start of project work, read `$HOME/.config/siverteh-ai/projects.json`.
A project with `build_host` uses that SSH host for heavy builds and tests;
`build_path` identifies its repository there. Keep editing in the selected local
project, transfer the exact task revision/changes to an isolated remote worktree,
and run long builds in tmux. Never overwrite another task’s checkout. Inspect
project instructions before choosing the build command.

Use one Git worktree per independent writing task. Preserve pre-existing edits
and active sessions. Remote workers run in tmux so disconnecting the laptop
does not stop them. Record handoff evidence and clean up only clean, idle task
worktrees once no more edits are needed. Follow each project's own workflow.

Give each new chat a concise, specific 3–7 word title once its task is clear.
Use the `siverteh_workflow.set_chat_title` MCP tool. Read `CODEX_THREAD_ID`
from your shell for its thread_id argument. This uses the supported naming API;
never edit the session database. Update the title if the task changes materially.
If the helper is unavailable, continue the task without repeatedly retrying.
