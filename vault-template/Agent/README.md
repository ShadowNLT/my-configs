---
type: meta
created: 2026-10-14
---

# Agent corner

This folder is the agent's. The operator does not edit it by hand. The agent reads and writes here. Nothing here should conflict with a note the operator maintains elsewhere in the vault.

## What lives here

- `INDEX.md` — dense index of every pattern. Check this before opening individual pattern files.
- `Patterns/<repo>/<slug>.md` — one durable technical fact per file. Each carries `verified_last`.
- `Feedback.md` — standing behavioral rules that fire on a specific action or context.
- `Dreams/` — logs of consolidation passes the agent runs over this corner.

Extra subfolders may already be here. Leave them in place.

## Why markdown and frontmatter

Plain markdown with YAML frontmatter is what the agent reads and writes reliably. Search and file reads work with no extra tooling. What makes the notes usable:

- The same frontmatter fields on every pattern, so entries scan and diff without re-parsing prose.
- Explicit `[[wikilinks]]` between related entries.
- `verified_last` on every technical claim, because code drifts and a stale claim should look stale.

## Pattern file schema

```yaml
---
type: pattern
repo: <repo-name>
scope: <short label>
confidence: high | medium | low
learned: <date first captured>
verified_last: <date last confirmed still true>
---

**Fact:** the durable claim, one or two sentences.

**Why it matters:** what breaks or gets misunderstood without this.

**Evidence:** what was observed (file, behavior, or test). Not an assertion alone.
```

Write or update a pattern only when a fact is durable and reusable, and refresh `INDEX.md` in the same pass. Reconfirming an existing fact bumps `verified_last` instead of adding a second file.
