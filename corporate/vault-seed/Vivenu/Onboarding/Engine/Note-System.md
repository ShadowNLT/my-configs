---
type: engine-rule
created: 2026-07-06
verified_last: 2026-07-06
---

# Note System: Lessons and Concepts

Why the curriculum has more than just `Modules/`, and how the pieces link together.

## The problem this solves

The 13-module prerequisite chain in [[../Curriculum-Map|Curriculum-Map]] is a fixed graph decided up front — useful for sequencing, but it's the same shape every time you look at it. It doesn't capture what's actually happened session to session, and it gives Obsidian's network view nothing interesting to show beyond one straight chain. Two more note types fix that:

- **`Lessons/`** — one note per taught session, dated. This is the record of what was actually said, not just "module M01 is done." Frontmatter: `module`, `date`, `hat`, `status` (`complete` or `in-progress` — mirrors Module notes' status field, but scoped to whether *this session* got cut short, not whether the module is mastered).
- **`Concepts/`** — one atomic note per recurring entity or term (`Checkout`, `Transaction`, `Ticket`, etc.). Short definition, nothing more. The point isn't the content, it's that every Lesson (and every Module) that touches that entity links to the same Concept note. One entity per note, even when two entities are usually introduced together (e.g. `Payment` and `PaymentRequest`) — bundling them blocks a later Lesson from linking to just one, and the whole point of this layer is atomic link targets.

## Why this produces a real graph

A Concept note like `Transaction` will eventually be linked from the M01 lesson (definitions), the M06 lesson (payment paths), the M07 lesson (lifecycle) — Obsidian's backlinks panel and network view surface that automatically. No manual "referenced by" list is maintained anywhere; that would just be restating what the links already say. The graph gets richer as more lessons happen, which is the actual mechanism for "seeing what's connected to what."

## Linking rules

- A Lesson note links back to its Module (`[[M0X-...]]`) and forward to every Concept it introduces or meaningfully touches.
- A Concept note links back to whichever Module first introduced it. It does not try to enumerate every Lesson that later references it — that's what backlinks are for.
- Don't create a Concept note for something that isn't going to recur across modules — a one-off implementation detail belongs in the Lesson note itself, not a new atomic note. If in doubt: would a future lesson plausibly link to this same term again? If no, it's not a Concept.
- **Restate only on first introduction.** The Lesson that first introduces a Concept gets the full definition in its body (this doubles as retrieval practice — writing the definition out is itself a stronger learning event than a bare link, which is why it's not just a link even though a link would be cheaper to maintain). A *later* Lesson that touches an already-documented Concept links to it rather than restating the definition — otherwise every repeat reference triples the surface a future correction has to track down.
- **Retrieval practice records the actual answer, not just the prompt.** A Lesson's retrieval section isn't a list of questions to be scored elsewhere — it's the record of what was answered, whether it was right, and anything noteworthy about the reasoning (especially answers that exceed what was taught, which is the strongest signal this curriculum can produce that real understanding is forming, not just recall). The Module note's Quiz Log stays a one-line score aggregate for the Progress Dashboard to scan; the Lesson note is where the substance lives.

## Lessons are historical snapshots, not living documents

A Lesson note records what was true and how it was explained on the date it was taught. If a Concept note it references later turns out to be wrong and gets corrected, **don't edit the old Lesson note to match** — that destroys the record of what was actually understood at the time, which is itself useful (it shows how understanding evolved, and lets you notice if the same misconception recurs). If a Lesson's claim is later found stale, annotate it (a line noting what changed and pointing at the corrected Concept note) rather than silently rewriting it. This is also why Lesson notes don't carry a `verified_last` field the way Concept notes do — a Lesson isn't meant to stay current, only accurate to what happened on its `date`.

## `/dream`'s carve-out for this corner

`/dream` treats `Vivenu/Onboarding/` as propose-only by default, since it's the user's own learning record, not the agent's housekeeping. `Lessons/` and `Concepts/` get exactly one exception — see the harness `/dream` command's "What to just do vs. propose" section for the exact rule rather than this file's paraphrase, since that's the source of truth and the two drifting apart is worse than one pointer. (Short version, subject to that file being more current: fixing a broken link is the only auto-apply action; merging Concept notes, tightening their wording, and touching their `verified_last`/`introduced_in` frontmatter are all propose-only, because a Concept note's body is itself a distilled piece of what was taught.)

`/dream` also actively scans `Concepts/` beyond link-fixing, surfacing (never creating or applying on its own) two more things as proposals: Concept notes that look like they describe the same entity, and an entity mentioned across multiple `Lessons/` notes that never got its own Concept note. Both are judgment calls for you, not the agent — see the same section of `dream.md`.
