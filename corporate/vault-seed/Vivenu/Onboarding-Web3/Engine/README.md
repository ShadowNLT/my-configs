---
type: meta
created: 2026-07-07
---

# Engine

This is the mechanical corner of the **web3-domain** onboarding curriculum: the rules the curriculum runs on, not the curriculum content itself. If you're looking for what to *learn*, go to [[../Curriculum-Map|Curriculum-Map]] or [[../Progress-Dashboard|Progress-Dashboard]] instead — this folder is about how the system stays accurate and how notes connect to each other.

This corner is a sibling of [[../../Onboarding/Engine/README|the checkout curriculum's Engine corner]], not a fork with drifted rules — the two are deliberately kept structurally identical (same five files, same responsibilities) so that switching between tracks via `/switch-track` never means relearning how the mechanics work, only which content is being taught. Where a rule is genuinely domain-specific (module count, keyword list, curriculum-root path) the two copies differ; where it's just methodology (the four hats, the Lessons/Concepts taxonomy, learning-science rationale) they say the same thing on purpose. See [[../../Onboarding/Engine/README|the checkout corner's own README]] for the fuller discussion of why sibling curricula duplicate this corner instead of sharing one copy.

## What lives here vs. what doesn't

- **This corner (`Engine/`)** — the rules: why the curriculum is shaped this way, the tutor personas, how it stays in sync with `apps/web3` in `vivenu-core`, and how notes link into a graph. Treat edits here as changing the rules, not just fixing a typo.
- **Content folders** (`Modules/`, `Lessons/`, `Concepts/`, `Curriculum-Map.md`, `Progress-Dashboard.md`) — what's actually being taught and your record of learning it.

## Structure

```
Engine/
  README.md              — this file

  Why and who:
  00-How-This-Works.md   — rationale, learning-science basis, cadence contract, session instructions
  Hats.md                 — the four tutor personas (same four as checkout's corner, kept in sync by convention)

  How the system stays honest:
  Sync-Core.md            — rationale for /sync-core on this track; defers to the real command file for mechanics
  Note-System.md          — the Lessons/Concepts note taxonomy and linking conventions
  Review-Logs/            — adversarial-review logs for command files touched by this curriculum,
                            one file per reviewed target, written whenever a command file changes
```

## Keeping this honest

`Sync-Core.md` and `Note-System.md` describe behavior that actually lives in the harness commands directory. When one of those files and the command it describes disagree, **the command file wins** — it's what executes. Don't trust a stale Engine doc over the real command; flag it and fix the doc, don't silently defer to whichever one you read first. Both files carry a `verified_last` date for the same reason.

## Relationship to the checkout curriculum and to `Agent/`

Modeled on [[../../Onboarding/Engine/README|the checkout curriculum's Engine corner]], which is itself modeled on `Agent/README.md` — same idea (a labeled home for mechanics rather than mixing them into content) one level further down the sibling chain. See [[../../Track-State|Track-State]] for how a session decides which of the two Engine corners applies when nothing else disambiguates it.
