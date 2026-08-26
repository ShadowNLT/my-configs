---
description: Close out an onboarding session — writes the Lesson note, updates Module/Dashboard state, verifies nothing was skipped
argument-hint: (no arguments needed)
---
<!-- Variables: {{VAULT_AGENT_DIR}} -> ~/Documents/DigitalBrain/Agent, {{AGENT_CONFIG_DIR}} -> ~/.claude|~/.cursor|~/.codex|~/.config/opencode, {{AGENT_COMMANDS_DIR}} -> {{AGENT_CONFIG_DIR}}/commands, {{AGENT_HARNESS_MEMORY}} -> harness memory path -->


# End Session

Vault root: `/Users/nlekanetamba/Documents/DigitalBrain`. This is the authoritative procedure for each track's `Engine/00-How-This-Works.md` end-of-session rule — those files point here rather than restating these steps, so there's one place this logic lives. You (the user) can invoke this at any time; Claude doesn't run it unprompted.

A module's own ID prefix (`M` or `W`) determines which curriculum root it belongs to (`Vivenu/Onboarding/` or `Vivenu/Onboarding-Web3/` — see `Vivenu/Track-State.md` for the full track table). Everything below operates per-module against that module's own track, not against `current-track` — a session resolved onto a specific track by `/new-session` writes to that track regardless of what's currently active.

**Known limit, stated plainly:** invoking this command guarantees a complete, consistent record *if it's invoked*. It doesn't guarantee invocation — a session that just trails off without anyone typing `/end-session` can still lose its record, the same way the original gap this command was built to close did. This is a real, open gap, not solved by this command; treat it as a convenience and a checklist, not a safety net.

## Steps

1. **Determine if this was a taught/quizzed session at all.** If no teaching content was delivered and no retrieval question was asked and answered (e.g. this was just an exploratory chat about a curriculum's own mechanics), say so and stop here — don't manufacture an empty Lesson note.
2. **For each module actually touched this session** (usually one on a single track; an interleaved quiz session may touch several, possibly across both tracks if explicitly asked for — repeat this step per module):
   - Write or update that module's own track's `Lessons/` note for today's date and that module: the actual questions asked, the actual answers given, and anything noteworthy about the reasoning (especially anything that exceeded what was taught). For a pure quiz/review session with no new teaching, skip "What was taught" rather than inventing filler.
   - **Filename:** `YYYY-MM-DD-<ID>-Title.md` (`<ID>` is that module's own prefix and number, e.g. `M03` or `W07`), where `Title` is copied verbatim from that module's own `Modules/<ID>-Title.md` filename (strip the `<ID>-` prefix). Before writing, check whether a same-day file for this module already exists — if so, update it in place rather than deriving a new slug. If this track's `Lessons/` folder doesn't exist yet (its first-ever taught/quizzed session), create it — same for `Concepts/` if this session introduces the track's first Concept note.
   - Mark the note's frontmatter `status: in-progress` if the session was cut short, otherwise `status: complete`.
3. **For each module touched, update its Module note** (in its own track's `Modules/` folder): frontmatter (`status`, `last_reviewed`, `next_review`), and Quiz Log — one row: date, score, and a short note on anything worth re-testing next review (not the full answers; those live in the Lesson note). If the session was cut short, also fill in **Session Notes** per that track's mid-module checkpoint convention.
4. **Update that module's own track's `Progress-Dashboard.md`** to match every Module note touched (a session spanning both tracks updates both dashboards, each with only the modules actually touched on that track).
5. **Verify before reporting done.** Re-read back what steps 2-4 actually produced: does each Module's Quiz Log entry link to a `Lessons/` file that exists on disk right now, and does that file's frontmatter `module`/`date` actually match what this session just wrote (not just that some file exists)? Does the relevant `Progress-Dashboard.md`'s row match the Module frontmatter you just wrote? If any check fails, fix it now — this step exists specifically so "I meant to" can't pass as "I did."
6. Report a short summary: what got written/updated (noting which track, if it wasn't obvious), current status of the module(s) touched, and what's next per that track's `Curriculum-Map.md`.
