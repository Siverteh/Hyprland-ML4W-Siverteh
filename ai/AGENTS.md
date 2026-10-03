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


For multi-step work, use the handoff reference in
`~/.agents/skills/siverteh-project-work/references/handoff.md` at meaningful
milestones and before ending unfinished work. On resume, retrieve that checkpoint
and verify current state. When durable findings conflict or a project reaches a
milestone, use `~/.agents/skills/siverteh-brain/references/maintenance.md` to
reconcile relevant notes without deleting historical evidence. Skip unchanged
checkpoints and trivial turns. These responsibilities apply to Codex and Claude.

Specialist skills are shared through `~/.agents/skills`, exposed to both assistants.
Use Obsidian Markdown/Bases/Canvas for vault presentation, Defuddle for clean web
extraction, frontend-design for visual UI, doc-coauthoring for substantial prose,
and pdf/docx/pptx/xlsx for those document formats. Keep repository-specific rules
and the private brain's storage policy authoritative. Install document tool
prerequisites in an isolated environment when needed; report unsupported rendering
rather than claiming visual verification. Never install dependencies into a
project merely because a general document skill lists them.

Use `siverteh-ai-tools python`, `siverteh-ai-tools node`, or
`siverteh-ai-tools defuddle` for installed isolated document/extraction tools.
Their environment is `~/.local/share/siverteh-ai/skill-tools`; it does not replace
project Python/Node environments. Some upstream document skills assume hosted
preinstalled tools: use this wrapper here. LibreOffice/Pandoc must be checked
separately before conversions; never claim rendering or formula recalculation
was verified if those tools were unavailable.

Start brain retrieval at INDEX.md and the relevant wiki page, then verify its
linked evidence. The vault's AGENTS.md / CLAUDE.md reference the shared policy.
Maintain current pages using siverteh-brain-maintain read/update with an expected
hash. Keep evidence notes append-only. Use siverteh-brain-maintain check after
substantial ingestion or reconciliation; do not invent a current fact from age alone.

## Conversation-first context and memory

New chats are general conversations, not assigned projects. Resolve the relevant
repositories only when the user requests work, using `siverteh-ai-context QUERY`
(or MCP `siverteh_workflow.resolve_context`). Keep the same chat across subjects.
Resolve ambiguity from the conversation and registry before asking; do not guess
which repository to modify. Registry build_host/build_path remain authoritative.

The brain includes personal life, ideas, research, devices and skills as well as
projects. At meaningful milestones, search existing evidence first, then use
`siverteh-ai-memory --title TITLE --source SOURCE --confidence reported|verified|unverified
--world SUBJECT --topic TOPIC` with a concise Markdown body on stdin. Repeat
--world to connect several subjects, and --topic for shared subtopics. Codex also
exposes find_knowledge and remember in siverteh_workflow; Claude uses the same CLI.
Keep entity names stable; reuse canonical wiki names/aliases. New subjects create
missing wiki descriptors automatically; this does not register a coding project.
Preserve existing curated pages and reconcile them through expected-hash updates.

Save decisions, outcomes, useful research and explicit personal preferences;
do not save every utterance, duplicate unchanged facts, transient output or raw
transcripts. User statements are reported; tested outcomes are verified; ideas
and hypotheses remain unverified. Link sources. Correct older facts explicitly.
The visual brain grows from dated evidence with activity decay, not message counts.
Meaningful new topics can emerge within existing worlds; promote a distinct new
world when it warrants its own stable subject. New repositories belong in the
project registry only when actually created or discovered and verified.
