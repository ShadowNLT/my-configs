---
description: Switch which onboarding curriculum sessions default to, or check the current one
argument-hint: [web3 | checkout | leave blank to just check]
---

# Switch Track

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`. Changes `current-track` in that vault's track-state file — the flag `/new-session` reads when a request doesn't name a track-prefixed module explicitly. See that track-state file itself for the full mechanics (why this file exists, how the staleness guard works, why module IDs are prefixed per track).

This command **only** changes routing. It never touches either curriculum's content, spaced-repetition state, or Progress Dashboards.

## Steps

1. Read `Vivenu/Track-State.md`'s current `current-track` value and its Tracks table. If the file is missing or its frontmatter doesn't parse, say so and stop — don't create or guess at a default; ask the user what `current-track` should be first.
2. **If `$ARGUMENTS` is empty:** report the current track and stop — this doubles as a "where am I" check. Don't proceed to step 3.
3. **If `$ARGUMENTS` names a track:** validate it matches a row in the Tracks table (see that table for the current list — don't hardcode track names here, since the table is the source of truth and may grow). If it doesn't match anything in the table, say so and stop — don't guess at a typo.
   - If it matches the **current** track already, say so (no-op) and stop.
   - Otherwise: update `Vivenu/Track-State.md`'s frontmatter `current-track` and `updated` fields (today's real date via `date +%F`, not ambient knowledge of the date), and update the "Current track" heading/line in the body to match, including a one-line reason if `$ARGUMENTS` or the surrounding conversation gave one (e.g. "switched back to checkout — onboarding a new hire this week"). If no reason was given, don't invent one.
4. Report the switch: old track → new track, and remind what didn't change (content, spaced-repetition state) so this doesn't read as bigger than it is.

## What this does not do

- Does not run `/new-session` — switching tracks doesn't start a session by itself. Say what the natural next module would be on the new track (per its `Curriculum-Map.md`) as a courtesy, but wait for the user to actually start one.
- Does not check either track's staleness — that's `/new-session`'s job (step 1, checks the *inactive* track for anything more than 7 days overdue), not this command's. Switching to a track doesn't retroactively need to justify itself against the other one's backlog.
