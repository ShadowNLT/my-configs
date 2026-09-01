---
description: Pause the current tracked work session — checkpoint state into the session note so a fresh agent session can resume it. Does not end the session.
argument-hint: [optional one-line reason for pausing]
---

# Pause Work

Use this when the current conversation needs to end (context limit, token budget, a break, switching machines) but the work itself is **not** done — contrast with `/end-work`, which closes the session out. The next agent session picks this up with `/resume-work`.

Vault root: `/Users/nlekanetamba/Documents/DigitalBrain`
Schema reference: `Work/00-How-Work-Tracking-Works.md` in that vault.

1. Determine the current repo (`git rev-parse --show-toplevel`, basename it). Then find the session note to pause, matching on *this chat*, not on recency:
   - Read the session identifier exposed by the current harness. Do not guess another harness's variable. If this harness exposes no session identifier, leave `agent_id` blank and match the work note by its stable `session_uid`.
   - Look under `Work/<repo>/Sessions/` for a `status: in-progress` note whose frontmatter `agent_id` equals that value. (On older notes the owner id may sit under the legacy `session_id` name — that legacy field is an *agent* id, distinct from the new stable `session_uid`; fall back to it. Never match on `session_uid` — it identifies the session, not the running agent.) **If exactly one matches, use it.**
   - **If none matches** (legacy note, or the in-progress notes belong to other agent sessions): do NOT silently pick the newest. List every `status: in-progress` note for the repo with its `goal` and `started_at`, and ask the user which one to pause (or none). Only proceed on their pick.
   - **If no `status: in-progress` note exists at all**, tell the user no tracked session is open — offer to run `/start-work` first, and stop.

2. Reconstruct current state: `git status` (and `git branch --show-current`), the last meaningful commands run this session, and what's confirmed working vs. not yet verified — from git plus your own memory of the conversation.

3. Update the session note in place:
   - Set `paused_at: <timestamp>` in the frontmatter (add the field if absent). Leave `status: in-progress` — a paused session is still logically open; `paused_at` being set is what marks it parked. Leave `ended_at` blank.
   - Overwrite (create if absent) a `## Handoff` section with these subsections, written so a fresh session with no memory of this conversation can act immediately:
     - `### What we were doing` — plain-language restatement of the current task.
     - `### Current state` — branch, uncommitted changes (`git status` summary), last meaningful command, confirmed working vs. not yet verified. **If `db_baseline: captured`, note that a local dev-DB baseline snapshot exists and lives on *this* machine** — a resume on another machine cannot restore from it (see the DB Baseline Protocol in `start-work.md`).
     - `### What's next` — the concrete next step, specific enough to act on cold without re-deriving context.
     - `### Open questions / blockers` — anything unresolved the next session must decide or ask the user about.
     - `### Relevant files` — paths (and line numbers where it matters) worth reading first next session.
     - `### Pedagogy` *(for every session that ran a tutorial — routine `4a`, code-review `4b`, issue-work `4c`, feature `4d`; omit only for a session with genuinely no tutorial)* — the checkpoint that lets `/resume-work` re-enter the teaching flow without losing a passed gate or re-quizzing it. Because one session can teach+gate more than one issue (TS-7 re-arms on each materially-different issue worked), this is a **per-work-item list**, not a single gate — one row per item worked this session:
       `- item: <short id/desc> | gate1: passed|open | gate2: passed|open|n/a | pos: step N of M|not-started|n/a | status: active|done|opted-out|parked`
       Plus the session `type:`, and — if the pause happened during `/end-work`'s sandbox — the sandbox path (the note's frontmatter already carries `sandbox: in-progress`). **Presentation is deliberately NOT recorded as durably done:** TS-7 requires each fresh session to re-present a still-open gate's material before running it, so there is no `presented:` flag to go stale. **Per-type notes:** `4c`/`4d` use all fields; **`4a`** the same, but gates were run *proportionately*; **`4b`** gates diff-comprehension only — `gate2: n/a`, `pos: n/a`. When a pause happens *inside* `/end-work`'s sandbox, `/end-work` writes this block itself rather than routing through `/pause-work`. See the Phase 1–4 flow in `start-work.md`, TS-7 in `Teaching-Standard.md`, and the sandbox step in `end-work.md`.
   - Append one line to `## Log`: `paused at <timestamp> — <reason>`, where `<reason>` is `$ARGUMENTS` if given, else a one-line inferred summary of the current task.

4. Tell the user in ≤2 lines: paused, the session note path, and that their next session should run `/resume-work` — it will detect and offer to resume this automatically. Keep it short.
