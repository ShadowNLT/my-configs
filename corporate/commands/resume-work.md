---
description: Resume a paused work session — reads the handoff from the session note and picks the work back up in this fresh agent session
argument-hint: (no arguments needed)
---

# Resume Work

Picks up a session paused with `/pause-work`. Run this at the start of a fresh agent session.

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`
Teaching Standard: `{{TEACHING_STANDARD_PATH}}`
Schema reference: `Work/00-How-Work-Tracking-Works.md` in that vault.

1. Determine the current repo (`git rev-parse --show-toplevel`, basename it). If it fails (not a git repo), tell the user and stop.

2. Find the session note under `Work/<repo>/Sessions/` with `paused_at` set in its frontmatter.
   - **None:** tell the user there's no paused session for this repo, offer `/start-work`, and stop.
   - **Migration:** if no `paused_at` note exists but a legacy `Work/<repo>/Handoff.md` sidecar does, fold its body into the referenced session note's `## Handoff` section, set `paused_at` from the sidecar's `handed_off_at`, delete the sidecar, then continue with that note.
   - **Exactly one:** use it.
   - **More than one:** list them (slug + `paused_at`), ask the user which to resume.

3. **Branch check:** compare `git branch --show-current` against the branch recorded in the note's `### Current state` (or the frontmatter `branch`). If they differ, warn the user before continuing — they may have switched branches since pausing — and confirm they want to resume here rather than switch back.

4. Read the note's `## Handoff` section and summarize its `### What's next` back to the user in 2-3 sentences so both sides are aligned on where things stand. **For any tutorial session (`4a`/`4b`/`4c`/`4d`), also read the `### Pedagogy` subsection** (if present) — it records how far the comprehension-gated tutorial / sandbox got, and step 7 re-enters at exactly that point.

5. Update the session note in place: clear `paused_at` (blank it), then **re-stamp `agent_id` — but leave `session_uid` exactly as it is.** These two do opposite things on resume:
   - `agent_id` → set to the session identifier exposed by the current harness, because resume runs in a **new** agent session. Add the field if the note predates it; a legacy note may carry this ownership id under the old `session_id` name instead — rename that to `agent_id` as you re-stamp. Re-stamping is what lets a later `/pause-work` or `/end-work` in this resuming session find the note by agent match — the paused note still carries the id of the agent session that paused it, which is no longer this one. If this harness exposes no session identifier, leave `agent_id` blank and use the stable `session_uid`.
   - `session_uid` → **do not change it.** It is the session's stable identity across every handoff; the whole point is that it stays constant no matter how many agents pass the work along. If the note predates `session_uid` and has none, back-fill one now with `uuidgen` (a one-time addition — this is the only place other than `/start-work` that ever writes it), so the resumed session gains a durable id going forward.

   Append a `## Log` line `resumed at <timestamp>`. If the note predates journaling and has no `## Journal` section, add an empty one now (placed after `## Goal`) so the rest of this session has somewhere to journal into.

6. Surface the same pre-flight `/start-work` step 3 does — **same one-line receipt** (Feedback, Patterns/<repo>, Parking-Lot open count for repo), then flag only hits relevant to this repo:
   - `Agent/Feedback.md` — standing behavioral rules (same as start-work step 3).
   - `Agent/Patterns/<repo>/` (see `Agent/README.md`) — durable facts about how this codebase behaves.
   - `Parking-Lot/INDEX.md` (see `Parking-Lot/README.md`) — filter by repo; open item files under `Parking-Lot/<repo>/` as needed. If a fix for one ships this session, flip its `status` to `resolved` in the item file **and** update its INDEX row.

7. Continue the work described in `### What's next`.

   **If this is a tutorial session (`4a`/`4b`/`4c`/`4d`) with a `### Pedagogy` checkpoint, re-enter the teaching flow at that point rather than restarting it** (see the Phase 1–4 flow in `start-work.md` and the sandbox step in `end-work.md`). For **4a** resume the proportionate gates/tutorial as recorded; for **4b** resume the diff-comprehension gate (there is no Phase 4). **`{{TEACHING_STANDARD_PATH}}` applies to the resumed teaching exactly as in the original session** — §Procedure + TS-1, TS-2, TS-3, TS-4, TS-5, TS-6, **TS-7 (re-present still-open gate material *this session* before running it)**:
   - **Do not re-quiz a `passed` gate** — treat `gate1: passed`/`gate2: passed` as already cleared (a `4b` session has only `gate1`; its `gate2` is `n/a`). **Resume an `open` gate by first re-presenting the material it tests this session, then running the ladder (TS-7)** — the 0→100 picture for an open Gate 1, the Phase-2 solution for an open Gate 2 — because presentation is not durably checkpointed. If the row carries `procedure: none` or `partial(…)` under the new schema, treat the prior teach as defective and re-run §Procedure before gating. Legacy rows with no `procedure:` field (`unrecorded`) do not invalidate an existing `gate1: passed`. Resume the tutorial at the recorded `step N of M`; don't restart from step 1.
   - **Multiple work-items in one `### Pedagogy` block** (a session that taught+gated issue A, then re-armed for issue B — see TS-7): re-enter **each item at its own recorded state**; a `passed`/`done` item stays cleared, an `open` item re-presents-then-gates per the rule above, an `opted-out` item is not re-taught. Match `gate1: passed` to the item it belongs to — never to the wrong issue.
   - **A materially-different issue surfacing after resume** is handled exactly as in `start-work` (the TS-7 fork): stop, surface **work-now vs park**; if worked, its fix-edit is blocked until its picture+solution are taught *this* session.
   - **If the note's frontmatter carries `sandbox: in-progress`**, the pause happened inside `/end-work`'s sandbox. Resume fixing the **existing** sandbox at the recorded path (don't rebuild it). When the user gets it green, **run `/end-work`'s finalize directly here** — **including the step-8 DB restore** (if `db_baseline: captured`, restore the local dev DB to its baseline and set `db_baseline: restored`, honoring the same guards as `end-work.md` step 8: never restore shared/remote infra, and if the snapshot is absent because this resume is on a different machine, record it in `## Follow-ups` and say so) — then set `sandbox: fixed`, write `ended_at`, flip `status: completed`, and append the closing `## Log` line. This is the *only* path that closes a paused-sandbox session; do **not** re-run `/end-work`'s steps 3/5/6 (they already ran before the pause), so there is no lesson re-offer and no duplicate owed-learning row. If the user still can't finish, it stays `in-progress` — pause again.
   - **If the `### Pedagogy` block is absent** (a legacy paused note from before this checkpoint existed), say so and reconstruct minimally from the `## Journal` rather than assuming which gates were passed.

   Follow the **Journal Protocol** (see `Work/00-How-Work-Tracking-Works.md`) for the rest of this session, exactly as `/start-work` does: append a typed `## Journal` entry at each trigger event (a domain fact learned, a root cause identified, an approach chosen, an approach abandoned). This must be carried here too, because a session that spans a pause/resume runs its second half in this fresh chat, and without this the journal would go dark after the resume. Reminder for the rest of this session (from global rules): never add an AI co-author trailer to commits, never stage `.agent/` into this repo, and if the conversation starts running long again, offer `/pause-work` before pushing through.
