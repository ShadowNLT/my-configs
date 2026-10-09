---
description: Pause the current tracked work session — checkpoint state into the session note so a fresh agent session can resume it. Does not end the session.
argument-hint: [optional one-line reason for pausing]
---

# Pause Work

Use this when the current conversation needs to end (context limit, token budget, a break, switching machines) but the work itself is **not** done — contrast with `/end-work`, which closes the session out. The next agent session picks this up with `/resume-work`.

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`
Code Concept Curriculum: `{{CODE_CONCEPT_CURRICULUM_DIR}}` — `discovery_status`, `chunks:`, and `passed_chunks:` on the item's row in the note's `## Pedagogy` section are the CCC receipts. Anything said to the learner here passes the term check (CCC G2f, with the internal-word denylist, CCC §2e), as defined in `start-work.md`.
Schema reference: `Work/00-How-Work-Tracking-Works.md` in that vault.

1. Determine the current repo (`git rev-parse --show-toplevel`, basename it). Then find the session note to pause, matching on *this chat*, not on recency:
   - Read the session identifier exposed by the current harness. Do not guess another harness's variable. If this harness exposes no session identifier, leave `agent_id` blank and match the work note by its stable `session_uid`.
   - Look under `Work/<repo>/Sessions/` for a `status: in-progress` note whose frontmatter `agent_id` equals that value. (On older notes the owner id may sit under the legacy `session_id` name — that legacy field is an *agent* id, distinct from the new stable `session_uid`; fall back to it. Never match on `session_uid` — it identifies the session, not the running agent.) **If exactly one matches, use it.**
   - **If none matches** (legacy note, or the in-progress notes belong to other agent sessions): do NOT silently pick the newest. List every `status: in-progress` note for the repo with its `goal` and `started_at`, and ask the user which one to pause (or none). Only proceed on their pick.
   - **If no `status: in-progress` note exists at all**, tell the user no tracked session is open — offer to run `/start-work` first, and stop.

2. Reconstruct current state: `git status` (and `git branch --show-current`), the last meaningful commands run this session, and what's confirmed working vs. not yet verified — from git plus your own memory of the conversation.

3. Update the session note in place:
   - Set `paused_at: <timestamp>` in the frontmatter (add the field if absent). Leave `status: in-progress` — a paused session is still logically open; `paused_at` being set is what marks it parked. Leave `ended_at` blank.
   - **Leave `## Lessons` exactly as it is** — it is the learner's teaching record. If a chunk passed this session and is missing from it, append it now per the Lessons rule in `start-work.md` step 8; never rewrite or drop an entry.
   - Overwrite (create if absent) a `## Handoff` section with these subsections, written so a fresh session with no memory of this conversation can act immediately:
     - `### What we were doing` — plain-language restatement of the current task.
     - `### Current state` — branch, uncommitted changes (`git status` summary), last meaningful command, confirmed working vs. not yet verified. **If `db_baseline: captured`, note that a local dev-DB baseline snapshot exists and lives on *this* machine** — a resume on another machine cannot restore from it (see the DB Baseline Protocol in `start-work.md`).
     - `### What's next` — the concrete next step, specific enough to act on cold without re-deriving context. **The teaching part is one plain line the learner can read:** what they have learned so far and what kind of thing comes next (e.g. *"Next: the rest of the plan for the fix, then you make the change."*). No chunk ids, no internal words (CCC §2e), and nothing that has not been taught yet — never the headline or claim of an unpassed chunk. The exact re-entry point lives in `## Pedagogy`, not here.
     - `### Open questions / blockers` — anything unresolved the next session must decide or ask the user about.
     - `### Relevant files` — paths (and line numbers where it matters) worth reading first next session.
   - **Refresh `## Pedagogy` in place** (start-work step 7 created it; format there). Never overwrite it and never move it into `## Handoff`: `## Handoff` is rewritten on every pause, `## Pedagogy` is not. Update each item's row from the live session; leave rows for other items as they are. If the note has no `## Pedagogy` section (a note from before this change), create it after `## Lessons`. If a legacy `### Pedagogy` block sits under `## Handoff`, move it verbatim into `## Pedagogy` and remove it from `## Handoff`. Skip this bullet only when nothing was taught (e.g. the escape hatch was used before any teaching).
     - **`chunks:` and `passed_chunks:` (required whenever any chunk was taught).** `chunks:` is this item's CCC chunk list in graph order: id, picture or solution, predecessor ids, a `stuck-added` marker for chunks CCC Phase H added, and a one-line claim. `passed_chunks:` is every chunk id that has a learner use-check pass. **On pause: make both match the live session.** `/resume-work` continues at the first unpassed chunk from them. Never list a chunk as passed without the learner's passing answer in this or an earlier session.
     - **`claims:`** is an optional sibling: the learner's passing answers, written **at Gate 1/2 pass** by `/start-work` (or resume re-entering those phases). **On pause: keep `claims:` as it is if present; if absent, leave absent — never invent claims from chat.**
     - **`discovery_status:`** is the discovery receipt (`pending` | `clear` | `escalated`), written by CCC in `/start-work` / `/resume-work`. **On pause: keep it as it is if present; if absent, leave absent — never invent it.** Optional siblings, kept the same way when present and left absent when absent: `convergence_status` (`pending` | `converged` | `escalated`) and `adversary_status` (`pending` | `clear`). A `discovery_status` other than `clear` blocks recording `gate1: passed`.
     - **Legacy rows:** a row written before this format may carry a `procedure:` field; keep it verbatim and do not add it to new rows. Absent `claims:`, `chunks:`, or `discovery_status` on a legacy row does **not** invalidate an existing `gate1: passed`.
     - **Presentation is deliberately NOT recorded as durably done:** `/resume-work` recaps the passed chunks and continues at the first unpassed one, so there is no `presented:` flag to go stale. See the Phase 1–4 flow in `start-work.md`.
   - Append one line to `## Log`: `paused at <timestamp> — <reason>`, where `<reason>` is `$ARGUMENTS` if given, else a one-line inferred summary of the current task.

4. Tell the user in ≤2 lines: paused, the session note path, and that their next session should run `/resume-work` — it will detect and offer to resume this automatically. Keep it short, and term-checked (no ids, no internal words).
