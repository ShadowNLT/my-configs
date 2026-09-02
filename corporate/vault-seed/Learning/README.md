---
type: engine-rule
created: 2026-07-08
---

# Learning — Ad Hoc, Freestanding Notes

Written and maintained by `/learn` and by `/end-work`'s durable-facts persistence step (step 5, which runs regardless of whether a lesson is taught; see the harness `/learn` and `/end-work` commands), never by `/new-session`/`/end-session`. Holds JIT topics and work-session learnings that don't belong to any vivenu-core onboarding track listed in `../Vivenu/Track-State.md`'s Tracks table (currently `../Vivenu/Onboarding/` and `../Vivenu/Onboarding-Web3/`) — a topic that does belong to a tracked track gets a real `Concepts/` note or a Module's "JIT Touches" section instead, never a note here. `/end-work` follows the same off-track-only rule: a durable fact from a work session that belongs to a track becomes a Concept, and only genuinely off-track learnings land here.

**Two sibling corners, distinct from these notes** (don't conflate): `../Work/Owed-Learning.md` is a plain queue of **deferred work-lessons** — a lesson postponed at `/end-work` (the "later" option) lands there and is resurfaced only in `/new-session` and `/learn`; unlike the notes here it carries **no** spaced-rep frontmatter (`next_review`/`ease`), it's just owed-until-taken. And the **external** tree `~/DigitalBrain-Sandboxes/` (outside this vault — see `../Sandboxes.md`) holds the runnable, tested standalone sandboxes `/end-work` builds for `issue-work`/`feature` sessions; those are hands-on drills, not review-scheduled notes, and are not scanned by `/dream` or `/new-session`.

## Schema

One living note per topic at `<slug>.md` — not a dated snapshot. Revisiting a topic updates the same note; `/learn` checks existing filenames for a close match before creating a new one, to avoid forking near-duplicates.

Frontmatter: `topic`, `first_learned`, `last_reviewed`, `next_review`, `interval_days`, `ease`, `repo`, `source_session`. The last two are provenance (same fields `Agent/Patterns` carries): `repo` is the repo the learning came from, `source_session` links back to the `Work/<repo>/Sessions/` note that spawned it. `/end-work` sets both when it first creates a note; on a revisit it preserves the note's original `source_session` and records the new session only in the Touches table, never overwriting `source_session`. `/learn` sets `repo` (the repo it's reading) and sets `source_session` only if a tracked work session is open, else leaves it blank. On a merge (a `/dream`-proposed consolidation of near-duplicates), keep the earliest `first_learned`/`source_session` and list every contributing `repo` rather than dropping provenance.

- **On creation:** seeded with this vault's standard first-exposure defaults — `ease: 2.5`, `interval_days: 1`, `next_review` one day out — the same starting values a new Module gets (cross-check against whatever a new Module's own seed values currently are, if these have since diverged). Never derived from `/learn`'s own retention check, which is an ungraded signal.
- **On revisit:** `last_reviewed` set to today always. `interval_days`/`next_review` only advance — doubling `interval_days` (capped at 90) and setting `next_review` that many days out from today — if the revisit happens on or after the note's current `next_review` date; an earlier touch (the same topic recurring same-day, say) hasn't yet demonstrated longer retention, so those fields are left as they were. `ease` stays frozen at its seeded value permanently — this branch never has a graded signal to justify moving it.

Body: the original scope/boundary statement ("this covers X, deliberately skips Y") kept visible on every future review, not just stated once — the point is to keep reinforcing what's still *not* known. Followed by a "Touches" table: `date`, `task unblocked`, `what was covered`.

## Staleness

`/new-session`'s Step 1 staleness glance also checks here for anything past `next_review`, nudge not gate, same treatment as the inactive-track check. `/learn` itself also glances here on every invocation, since the population most likely to generate these notes is exactly the population least likely to run `/new-session` regularly.

## Consolidation

Duplicate or near-duplicate notes that slip through slug-matching are `/dream`'s job to catch on its periodic pass — confirmed in the harness `/dream` command's Scope and Connect sections, which explicitly cover `Learning/` the same way they already cover `Concepts/`.
