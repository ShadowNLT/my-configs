---
description: Close out the current tracked work session and record what happened in the DigitalBrain vault
argument-hint: (no arguments needed)
---

# End Work

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`
Code Concept Curriculum: `{{CODE_CONCEPT_CURRICULUM_DIR}}` — everything said to the learner here (the step-6 confirm and any question) passes the term check (CCC G2f, with the internal-word denylist, CCC §2e), as defined in `start-work.md`: no chunk ids or internal words, and code words only if a lesson taught them or the line defines them.

1. Determine the current repo (`git rev-parse --show-toplevel`, basename it). Then find the session note to close, matching on *this agent session*, not on recency:
   - Read the session identifier exposed by the current harness. Do not guess another harness's variable. If this harness exposes no session identifier, leave `agent_id` blank and match the work note by its stable `session_uid`.
   - Look under `Work/<repo>/Sessions/` for a `status: in-progress` note whose frontmatter `agent_id` equals that value. (On older notes the owner id may sit under the legacy `session_id` name — that legacy field is an *agent* id, distinct from the new stable `session_uid`; fall back to it. Never match on `session_uid` — it identifies the session across agents, not the running agent.) **If exactly one matches, use it** — this is the normal path and closes the session this agent actually started.
   - **If none matches** (a legacy note predating the `agent_id` field, or every in-progress note belongs to another agent session): do NOT silently pick the newest — that's the bug this matching exists to prevent. List every `status: in-progress` note for the repo with its `goal` and `started_at`, and ask the user which one to close (or whether to close none). Only proceed on their pick.
   - **If no `status: in-progress` note exists at all**, do not fabricate one from git (with no note there's no `agent_id`/start-point to bound *this* session's commits). If real work happened without a tracked session, tell the user the session was untracked and **offer to create a note now, asking them for the goal** (user-supplied, not git-inferred). If they decline, leave it untracked and stop — never invent one silently.

2. Reconstruct what happened this session:
   - `git status` and `git diff --stat` (and `git log <since-session-start-if-known>..HEAD` if commits were made) to get the real file list and commit history.
   - The note's `## Journal` (see the Journal Protocol in `Work/00-How-Work-Tracking-Works.md`), the running typed capture written during the session. This is the reliable source for the `domain`/`issue`/`decision`/`dead-end` reasoning that git can't reconstruct; prefer it over memory where they differ.
   - Your own knowledge of the conversation: what was the actual goal outcome, what approach was taken, what was tried and abandoned, what's left undone.

3. Update the session note in place and **complete the session here** (every session completes in this step; completing the note does **not** end the command — steps 4–6 still run):
   - Write `ended_at: <now>` and flip `status: completed`. If `paused_at` is set (ended directly from a paused state), clear it.
   - `## Files Touched`: real file list from git, not a guess.
   - `## Decisions`: notable choices made and why (skip if genuinely nothing decision-worthy happened).
   - `## Follow-ups`: anything left open, deferred, or discovered but out of scope — be concrete, this is what future-you or a teammate reads to know what's unfinished.
   - Leave `## Lessons` exactly as it is (it is the session's teaching record). If a chunk passed and is missing from it, append it per the Lessons rule in `start-work.md` step 8. Leave `## Pedagogy` as it is too, except to mark finished items `status: done`.
   - Append a closing `## Log` line with a short outcome summary.

4. If a legacy `Work/<repo>/Handoff.md` sidecar exists (from before the pause/resume split), fold its content into this note's Decisions/Follow-ups as relevant, then delete it — no dangling handoff should remain. The note's own `## Handoff` section can stay as-is; it's part of the session's record.

5. **Persist the session's durable facts to their homes.** This runs unconditionally for every session. Do it as one pass so each fact is judged once:
   - **Enumerate candidates.** From the `## Journal` (see the Journal Protocol in `Work/00-How-Work-Tracking-Works.md`), `git`, and this conversation, list the durable facts the session produced. Apply `/learn` Step 6's filter and skip trivial one-offs. A genuinely mechanical session yields none, which is expected: skip the rest of this step.
   - **Classify each once** via `/learn` Step 2's A/B/C/D branching (including its disambiguation-ask and merge-candidate flagging). Durability test: a fact that stays true after this fix ships.
   - **Route each to its existing home** (no parallel corpus) and save it silently, with no per-note prompt:
     - repo gotcha or codebase behavior goes to `Agent/Patterns/<repo>/` under Patterns' own high bar, following the schema exactly (`type`, `repo`, `scope`, `confidence`, `learned`, `verified_last`, `source_session`; Fact / Why it matters / Evidence), and update `Agent/INDEX.md`'s table to match. If a pattern for this exact fact already exists and is simply reconfirmed, bump `verified_last` instead of duplicating. This is a high bar: most sessions produce none, so don't manufacture one.
     - a concept belonging to an onboarding track extends or creates a `Concepts/` note (`/learn` A/C).
     - an off-track learning becomes a freestanding `Learning/<slug>.md` note (`/learn` D), seeded per `Learning/README.md`, its body carrying enough to relearn cold, with `repo` and `source_session` frontmatter. `/end-work` is a documented second writer of `Learning/` (see that README).
   - **Dedup before writing.** Check existing notes for a close match first. On a match, update that note as a revisit (`/learn` Branch D: append a Touches row, and preserve the note's original `source_session`) rather than forking a near-duplicate.
   - **Verify.** Check each new note's spaced-rep frontmatter against the fixed seed constants in `Learning/README.md` (`ease: 2.5`, `interval_days: 1`, `next_review` +1 day), not a self-authored expectation, since a frozen `ease` mis-seed is never corrected later.
   - **Stale vault corrections.** Scan the session note's `## Follow-ups` for lines marked **Stale** (a vault note contradicted by live code, queued during the session). For each: update the named vault note to match the code (or mark superseded with evidence), remove the follow-up line, and say so in the step-6 confirm.
   - **If a save fails partway**, record each fact that did not persist in `## Follow-ups` (the fact, its intended home, and why it failed) and surface it in step 6 so it is not lost silently. This is a manual to-do for you to action, there is no automatic retry. Re-running `/end-work` will not re-persist on its own: the session was completed in step 3, so it is no longer `in-progress`, so step 1 will not reopen it, and dedup guards duplicates if it is reopened deliberately.

6. **Restore the local dev DB, then confirm.**
   *DB restore (runs at every close):* if the session note's `db_baseline` is `captured`, restore the local dev DB to that baseline now, from the snapshot recorded in `## DB Baseline` (see the DB Baseline Protocol in `start-work.md`). This reverts **all** local dev-DB state created this session — the env-setup seeds/fixtures/flags — returning it to its start-of-session baseline; it is blunt by design (it also discards any unrelated dev data added this session, and any deliverable migration's *local* effects, which re-apply from the repo). Then set `db_baseline: restored` and append a `## DB Baseline` line with the restore + `date`.
   - **Guards.** Re-confirm the target is the local/disposable DB the baseline names before running — **never restore shared/staging/remote infra.** If the snapshot is absent (a cross-machine close — it lives on the machine that captured it) or the restore command errors, do **not** silently pass: record the failure in `## Follow-ups` (what didn't restore, the DB target, the error) and surface it in the confirm, so leftover state is visible. If `db_baseline` is `none` (no local DB, an ephemeral DB, or a shared-DB skip), there is nothing to restore — skip the restore. Say so in the confirm ("nothing to restore") only if a database came up in this session; otherwise leave the database line out (housekeeping rule in `start-work.md`).
   *Confirm* to the user in 2-3 plain, term-checked sentences, kept minimal (housekeeping rule in `start-work.md`): what got done, what's left and whose next step it is, and where the session notes are saved. Then add one plain line on what was saved for later (e.g. *"I saved two short notes about what we learned today, for next time."*; give paths in code formatting only if useful, never unexplained folder names), and, when a database came up in this session, **one plain line on the database** (put back as it was, or what is left over if putting it back failed). If any fact failed to persist, call it out explicitly. Do not ask the user to re-explain what happened — derive it from git, the Journal, and the conversation.
