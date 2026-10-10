# Knowledge helper source audit

Review all six current bin/siverteh-ai-{context,memory,usage} and
bin/siverteh-brain{,-maintain,-sync} bodies and their local authoring/change
history. Trace native subprocess/SSH/Markdown/SQLite/HTTP/SDK interfaces and
private state boundaries. Retain proven own work with individual SHA evidence;
replace uncertain inherited implementations from behavior contracts, recording
prior exposure, without consulting the old/upstream body while writing.

Never run real note ingestion, vault setup/sync/restore, account/remote login,
credentials queries or worker launch for audit QA. Existing fixtures use fake
native services and temporary home/vault/configuration; preserve full-access AI
and update policy. Native libraries/services remain licensed dependencies.
No private knowledge or accounts belong in the repository.

One isolated branch, full native checks, plan and live source/IPC validation.
Audit-only documents do not need a redundant runtime deployment. Source fixes
need a demonstrated regression and reviewed appropriate-owner deployment.
Keep all notices until remaining controllers/Brain/fixtures/docs and whole-tree
comparison support the final provenance/licensing conclusion.
