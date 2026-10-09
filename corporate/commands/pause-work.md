---
description: Pause the current tracked work session — checkpoint state into the session note so a fresh agent session can resume it. Does not end the session.
argument-hint: [optional one-line reason for pausing]
---

# Pause Work

Use this when the current conversation needs to end (context limit, token budget, a break, switching machines) but the work itself is **not** done — contrast with `/end-work`, which closes the session out. The next agent session picks this up with `/resume-work`.

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`
Code Concept Curriculum: `{{CODE_CONCEPT_CURRICULUM_DIR}}` — `discovery_status`, `chunks:`, and `passed_chunks:` on the Pedagogy row are the CCC receipts.
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
     - `### What's next` — the concrete next step, specific enough to act on cold without re-deriving context.
     - `### Open questions / blockers` — anything unresolved the next session must decide or ask the user about.
     - `### Relevant files` — paths (and line numbers where it matters) worth reading first next session.
     - `### Pedagogy` *(for every session that taught at least one chunk; omit only when nothing was taught, e.g. the escape hatch was used before any teaching)* — the checkpoint that lets `/resume-work` re-enter the teaching flow without losing a passed chunk or re-quizzing it. Because one session can teach+gate more than one issue (the new-issue fork in `start-work.md` re-arms on each materially-different issue worked), this is a **per-work-item list**, not a single gate — one row per item worked this session:
       ```
       - item: <short id/desc> | gate1: passed|open | gate2: passed|open|n/a | pos: step N of M|not-started|n/a | status: active|done|opted-out|parked
         chunks: <id> (picture|solution; after <pred ids or ->)[; stuck-added]: <one-line claim>; ...
         passed_chunks: <id>, <id>, ...
         claims: G1: <learner answer>; <learner answer> | G2: <answers or empty>
         discovery_status: pending|clear|escalated
         convergence_status: pending|converged|escalated
         adversary_status: pending|clear
       ```
       The pipe fields stay the authority for passed/open. `gate2: n/a` and `pos: n/a` when the goal changes no code in this repo (a review).
       - **`chunks:` and `passed_chunks:` (required whenever any chunk was taught).** `chunks:` is this item's CCC chunk list in graph order: id, picture or solution, predecessor ids, a `stuck-added` marker for chunks CCC Phase H added, and a one-line claim. `passed_chunks:` is every chunk id that has a learner use-check pass. **On pause: write both from the live session.** `/resume-work` continues at the first unpassed chunk from them. Never list a chunk as passed without the learner's passing answer in this or an earlier session.
       - **`claims:`** is an optional sibling: the learner's passing answers, written **at Gate 1/2 pass** by `/start-work` (or resume re-entering those phases). **On pause: copy `claims:` verbatim if present; if absent, leave absent — never invent claims from chat.**
       - **`discovery_status:`** is the discovery receipt (`pending` | `clear` | `escalated`), written by CCC in `/start-work` / `/resume-work`. **On pause: copy it verbatim if present; if absent, leave absent — never invent it.** Optional siblings, copied verbatim the same way when present and left absent when absent: `convergence_status` (`pending` | `converged` | `escalated`) and `adversary_status` (`pending` | `clear`). A `discovery_status` other than `clear` blocks recording `gate1: passed`.
       - **Legacy rows:** a row written before this format may carry a `procedure:` field; copy it verbatim and do not add it to new rows. Absent `claims:`, `chunks:`, or `discovery_status` on a legacy row does **not** invalidate an existing `gate1: passed`.
       - **Presentation is deliberately NOT recorded as durably done:** `/resume-work` recaps the passed chunks and continues at the first unpassed one, so there is no `presented:` flag to go stale. See the Phase 1–4 flow in `start-work.md`.
   - Append one line to `## Log`: `paused at <timestamp> — <reason>`, where `<reason>` is `$ARGUMENTS` if given, else a one-line inferred summary of the current task.

4. Tell the user in ≤2 lines: paused, the session note path, and that their next session should run `/resume-work` — it will detect and offer to resume this automatically. Keep it short.
