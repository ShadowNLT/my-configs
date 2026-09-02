---
type: meta
created: 2026-07-06
---

# Engine

This is the mechanical corner of the checkout-domain onboarding curriculum: the rules the curriculum runs on, not the curriculum content itself. If you're looking for what to *learn*, go to [[../Curriculum-Map|Curriculum-Map]] or [[../Progress-Dashboard|Progress-Dashboard]] instead — this folder is about how the system stays accurate and how notes connect to each other.

## What lives here vs. what doesn't

- **This corner (`Engine/`)** — the rules: why the curriculum is shaped this way, the tutor personas, how it stays in sync with `vivenu-core`, and how notes link into a graph. You can read and edit this like any other note, but it's Claude's reference for *how to run a session*, so treat edits here as changing the rules, not just fixing a typo.
- **Content folders** (`Modules/`, `Lessons/`, `Concepts/`, `Curriculum-Map.md`, `Progress-Dashboard.md`) — what's actually being taught and your record of learning it.

## Structure

```
Engine/
  README.md              — this file

  Why and who:
  00-How-This-Works.md   — rationale, learning-science basis, cadence contract, session instructions
  Hats.md                 — the four tutor personas

  How the system stays honest:
  Sync-Core.md            — rationale for /sync-core; defers to the real command file for mechanics
  Note-System.md          — the Lessons/Concepts note taxonomy and linking conventions
  Review-Logs/            — adversarial-review logs for command files touched by this curriculum,
                            one file per reviewed target, written whenever a command file changes
```

The two groups aren't a folder split — just a way to read the tree at a glance. The first group is prose you read for understanding; nothing executes against it. The second group describes or records the behavior of actual slash commands (`/sync-core`, `/dream`), so editing it changes what those commands mean to a reader, and it's held to a different standard (see "Keeping this honest" below).

## Keeping this honest

`Sync-Core.md` and `Note-System.md` describe behavior that actually lives in the harness commands directory. When one of those files and the command it describes disagree, **the command file wins** — it's what executes. Don't trust a stale Engine doc over the real command; flag it and fix the doc, don't silently defer to whichever one you read first. This is why both files carry a `verified_last` date: if it's old and the command file has changed since, treat the doc as unverified rather than authoritative.

## Relationship to `Agent/`

This corner is modeled on [[../../Agent/README|Claude's Corner]] one folder up — same idea (a labeled home for mechanics rather than mixing them into content), same bias toward dense frontmatter and explicit `[[wikilinks]]` so the rules themselves stay a traversable graph. It's a separate corner rather than a subfolder of `Agent/` because it's about *this specific curriculum's* machinery, not general cross-repo technical knowledge.
