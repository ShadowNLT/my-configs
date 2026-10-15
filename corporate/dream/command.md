---
description: Periodic consolidation pass that reads the whole vault, writes only its own log in Agent/Dreams/, and proposes every other change
argument-hint: (no arguments needed)
---

# Dream

A maintenance ritual, not a work session. The goal mirrors what sleep-driven memory consolidation does biologically: strengthen what's still true, prune what's gone stale, connect facts captured separately but related, and surface insights only visible when looking across everything at once rather than one file at a time.

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`

Two helper files sit next to this command: `seed_state.py` checks that the
vault is seeded, and `install.sh` installs the command. They're in
`corporate/dream/` in the repo and in `$CONFIG_DIR/dream/` after install. If
the path given to `install.sh` is not a seeded vault, it installs nothing for
that harness.

## Start check
Run `python3 <this folder>/seed_state.py "{{KNOWLEDGE_VAULT_ROOT}}"`. If it exits 1, show its one reason line and stop. Nothing is read or written.

## Scope
- **Reads:** the whole vault under `{{KNOWLEDGE_VAULT_ROOT}}`, `legacy/` included, every folder in it, including folders added after this file was written, except `.obsidian/`, which it never reads.
- **Writes:** only `{{KNOWLEDGE_VAULT_ROOT}}/Agent/Dreams/`. A dream pass writes, moves or deletes nothing else, in the vault or outside it. Every other change is a proposal in the dream log.

## Short-circuit
Before doing anything else, check whether anything's actually changed since the last `Agent/Dreams/*.md` entry (new or edited notes anywhere in the vault). If nothing's new, say so in one line and stop — don't run a full pass for no material.

## Process
1. **Re-verify patterns** in `Agent/Patterns/<repo>/`, especially stale `verified_last` dates — grep the real repo for the referenced file/class/behavior.
   - Confirmed → **propose** bumping `verified_last` to today; list it in the dream log.
   - Drifted → **propose** the correction to the user rather than silently rewriting the Fact; a wrong technical claim written here doesn't stay contained, it resurfaces later wherever the pattern is read.
2. **Connect** — **propose** missing `[[wikilinks]]` between facts captured separately that actually relate (a pattern that should reference a decision note it depends on).
3. **Surface insights** — what's true in aggregate that isn't visible from any single file (a recurring struggle area, a cadence that's drifted, scope creep, a contradiction between two memories)? State the evidence basis inline ("based on 3 sessions," not asserted as settled fact) so it's calibrated, not just confident-sounding. Only report a real one — don't manufacture an insight to have something to say.

## What to write vs. what to propose
- **The only write:** the dream log `Agent/Dreams/<date>.md` (Output below). Nothing else is applied, not even housekeeping inside `Agent/`.
- **Propose, don't apply:** housekeeping inside `Agent/` (merging exact duplicates, fixing links, bumping `verified_last` on a confirmed pattern); rewriting a pattern's stated Fact (even though it's inside `Agent/` — wrong facts propagate back out); and anything else in the vault that represents the user's own facts/decisions rather than the agent's own housekeeping.

## Output
Write `{{KNOWLEDGE_VAULT_ROOT}}/Agent/Dreams/<date>.md`, the only file a dream pass writes: what was reviewed, any insight surfaced (with its evidence basis), and everything proposed for the user's review. A dream that found nothing gets a two-line entry, not padding.
