---
type: meta
created: 2026-07-02
---

# Claude's Corner

This folder is Claude's — by agreement, you don't edit it. Claude reads and writes here freely; nothing here should ever conflict with something you were maintaining by hand.

## What lives here vs. what doesn't

*Reorganized 2026-07-24: Claude Code's harness memory was demoted to a non-authoritative cache and emptied; its durable content moved here and into `AGENT.md`.*

1. **Claude Code's own memory system** (the agent harness memory directory, outside this vault): now a non-authoritative *cache* only, not a source of truth. It stays where it is (the harness injects tracking metadata on write) but should be near-empty. On any conflict, this vault, the seeded harness `AGENT.md`, and the installed harness command files win — see `AGENT.md`'s "Two-tier memory > Trust order."
2. **This corner** (`Agent/` in your vault) — durable knowledge Claude relies on, in two kinds:
   - `Patterns/<repo>/`: *repo-specific technical knowledge* (patterns, gotchas) discovered while doing programming work. Each carries a `verified_last` staleness field.
   - `Feedback.md`: *standing behavioral rules* that fire on a specific action or context (git, PR, CI, web3, the vault). Read by `/start-work` at session start. (Rules that must fire on every response regardless of action — writing style, edit scope, adversarial review — live in `AGENT.md` instead, since this vault is not auto-loaded.)

## Why markdown + frontmatter, not something more exotic

Plain markdown with YAML frontmatter is what Claude reads and writes most reliably — no format conversion overhead, no compatibility loss with Obsidian if you ever do look in here, and `grep`/`Read` both work on it without any special tooling. The lever that actually matters for "encoding this well for an LLM" isn't the file format, it's:
- **Consistent, dense frontmatter** (same fields every time) so entries are scannable and diffable without re-parsing prose.
- **Explicit `[[wikilinks]]`** between related entries, so this becomes a real traversable graph instead of a pile of isolated notes.
- **A staleness field** (`verified_last`) on every technical claim, because code drifts and a memory system for a codebase needs to know when to distrust itself — this is the one thing that's genuinely different from how Claude Code's own memory (facts about you) is encoded, since those don't rot the same way code does.

## Structure

```
Agent/
  README.md      — this file
  INDEX.md        — dense index of every pattern below, always check this first
  Feedback.md     — standing behavioral rules (git/PR/CI/web3/vault workflow); read by /start-work
  Patterns/
    <repo-name>/
      <slug>.md   — one durable technical fact per file
  Dreams/
    <date>.md     — log of each /dream consolidation run
```

## Dreaming

`/dream` is a periodic maintenance ritual (run it whatever cadence you like — daily, weekly) that consolidates harness memory, re-verifies patterns against the real repos, mines session logs for unresolved themes, checks onboarding health, and connects facts that were captured separately but relate — the same job sleep-driven memory consolidation does biologically. It edits freely inside `Agent/` for routine housekeeping, but proposes rather than silently applies anything that rewrites a stated fact or touches `Work/`/`Onboarding/`. Each run logs to `Dreams/<date>.md`. See the harness `/dream` command for the full process.

## Pattern file schema

```yaml
---
type: pattern
repo: <repo-name>
scope: <short label, e.g. "checkout-locking">
confidence: high | medium | low
learned: <date first captured>
verified_last: <date last confirmed still true>
source_session: <[[link]] to the Work/<repo>/Sessions/*.md note it came from, if any>
---

**Fact:** the actual durable claim, one or two sentences.

**Why it matters:** what breaks or gets misunderstood without knowing this.

**Evidence:** what was actually observed (file/class/behavior/test run) — not just an assertion.
```

## How this gets fed

`/start-work` checks `Patterns/<repo>/` for anything relevant to the stated goal before diving in. `/end-work` looks at what actually happened in the session and, only if something genuinely durable and reusable surfaced, writes or updates a pattern file here and refreshes `INDEX.md` — it doesn't manufacture entries just to have something to write. See `Work/00-How-Work-Tracking-Works.md` for the full session-tracking system this feeds into.
