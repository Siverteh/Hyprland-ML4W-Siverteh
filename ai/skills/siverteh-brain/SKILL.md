---
name: siverteh-brain
description: Retrieve or save durable personal knowledge, host/device facts, project context, and operational lessons in Siverteh's private local Markdown vault.
---

# Siverteh Brain

The vault lives at `$HOME/Documents/Siverteh-Brain`, independent of ChatGPT
accounts. Use `siverteh-brain path` if the user configured a different location.

Search relevant terms before reading entire folders. Prefer verified, recent
notes; inspect the cited source when the fact controls an operation. Host
addresses are dated observations, so verify machine identity before changing it.
Repo-local instructions and specs stay authoritative for code and deployment.

When work establishes a reusable fact, record a concise note with the CLI:

```sh
siverteh-brain note --kind runbooks --title 'Short factual title' \
  --source 'Exact local file, command evidence, or source URL' --confidence verified
```

Supply Markdown on stdin. Include what was observed, verification date, relevant
commands, practical limits, and next step where needed. Choose `reported` for
user statements and `unverified` for claims that have not been checked. Each call
creates a unique file, so concurrent chats can safely add notes. Organize existing
notes without rewriting other active tasks' files.

Never store secret values. Credential notes contain OS keyring references only.
The helper rejects common credential patterns but is not a complete detector;
review the text. Never sync private vault content or account state into the
public OS repo. Ordinary ChatGPT web memory is a separate system and does not
automatically read this folder.
