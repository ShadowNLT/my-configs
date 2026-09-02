---
type: meta
created: 2026-07-06
---

# DigitalBrain

Vault root. Top-level folders: `Personal/`, `Vivenu/`, `Work/` (session tracking, see `Work/00-How-Work-Tracking-Works.md`), `Agent/` (Claude's own corner — see `Agent/README.md`, the user never reads or edits it).

## Diagrams

*Added 2026-07-06, adversarially reviewed same day — revisit if this stops fitting or misfires in practice (note it here with a date rather than silently re-deciding it in some future chat).*

Applies to anything Claude writes in this vault meant for the user to read. Does not apply to `Agent/` — that corner is Claude's own operational reference, and Claude uses whatever format serves its own future comprehension there, diagram or not.

**Use a diagram when a relationship, sequence, state machine, or hierarchy is structural** — the note's own content depends on the reader understanding how the pieces connect — **not when things are only co-mentioned.** Three services named in one sentence with no dependency between them isn't a diagram case; three services where the note's whole point is how they call each other is. Concretely:
- **A structural relationship between 3+ things** → flowchart or graph
- **A sequence of steps across time or across actors/systems** → sequence diagram
- **A state machine or lifecycle** → state diagram
- **A hierarchy or prerequisite ordering** → flowchart/tree
- **A comparison across options or attributes** → a markdown table, not a diagram — tables are the right tool for this shape, Mermaid isn't
- **A genuine data-relationship model** (entities and their fields) → an ER diagram, if a table would be unreadable

**Skip a diagram even when a shape above technically matches, if it would be trivial** (2 nodes, a straight A→B, nothing a sentence doesn't already say) **or capped by size** — past roughly 12-15 nodes, break it into linked sub-diagrams or fall back to a table rather than shipping one dense chart. This cuts both ways on purpose: required when a match is real and adds clarity, skipped when a match is technical but adds nothing. Neither "does this obviously help" nor "does this match a listed shape" is sufficient alone — both have to be true.

**Every diagram gets at least one sentence of prose alongside it** stating what it shows — never let a Mermaid block be the only carrier of the information, since it won't render outside Obsidian (plain-text viewing, a tool without Mermaid support) and a syntax error would otherwise leave the note silently broken.

**Exemptions, not oversights:**
- `Vivenu/Onboarding/Concepts/` and `Lessons/` — these are deliberately atomic (one idea per note, per `Onboarding/Engine/Note-System.md`); relationships between concepts show up as backlinks and the Obsidian graph view, not as an in-note diagram repeating what the links already say.
- `Work/*/Sessions/*.md`'s `## Log` section — append-only chronological narration by design (see `Work/00-How-Work-Tracking-Works.md`), exempt the same way prose-style rules exempt logs elsewhere. The rest of a session note (a handoff conveying real state, a `Decisions` section with a real branch point) isn't exempt just for living in `Work/`.

**Rollout:** new content follows this from today. Existing notes aren't retrofitted wholesale, but if an old note is already being touched for any reason and it clearly qualifies with no diagram, say so and offer to add one rather than leaving it silently as-is.

**Scope note:** `Onboarding/Engine/` is in scope even though Claude mostly maintains it, because its own README says the user can read and edit it like any other note — unlike `Agent/`, which is explicitly hands-off for the user. Confirmed with the user 2026-07-06: "the claude corner" means the `Agent/` folder specifically, not a broader "anything Claude mostly writes" rule.

Mermaid blocks (node labels, edge text) aren't held to the seeded harness `AGENT.md` Writing style section (no em dashes, first-principles framing, etc.) — keep labels terse, that section is about connected prose, not diagram text.
