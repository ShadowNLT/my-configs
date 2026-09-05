---
type: work-meta
created: 2026-07-02
---

# How Work Tracking Works

Every programming session in a repo under `~/Developer/` gets logged here, driven by four global work commands (`/start-work`, `/pause-work`, `/resume-work`, `/end-work` — installed in the harness commands directory). This corner is separate from [[../Vivenu/Onboarding/Engine/00-How-This-Works|the onboarding curriculum]] — that's learning, this is a record of actual work done.

## Structure

```
Work/
  <repo-name>/
    Sessions/
      YYYY-MM-DD-HHmm-<slug>.md   — one file per work session
```

A session paused mid-work carries `paused_at` in its frontmatter and a `## Handoff` section in the note itself — no separate sidecar file. (Older sessions used a `Handoff.md` sidecar; it's folded in and deleted on the next resume or end-work.)

`<repo-name>` is derived from the git repo's top-level directory name (e.g. `vivenu-core`, `go`), so this scales to any repo without needing setup per project.

## Session note schema

```yaml
---
repo: <name>
branch: <working branch cut for this session (see /start-work git-flow)>
type: routine | code-review | issue-work | feature
started_at: <timestamp>
ended_at:
status: in-progress | completed
session_uid: <stable unique id for this session, generated once with `uuidgen`, never changed — agent-agnostic>
agent_id: <currently-owning agent session id — each agent stamps its own: Claude Code's CLAUDE_CODE_SESSION_ID, Cursor's CURSOR_CONVERSATION_ID, etc.>
goal: <one-line stated goal>
db_baseline: none | captured | restored
continues: <prior session_uid> [[prior note path]]   # optional — only on a follow-up session (see below)
---
```
Sections: `## Goal`, `## Journal`, `## Log`, `## Files Touched`, `## Decisions`, `## Follow-ups`, `## DB Baseline`. A paused session also carries `paused_at` in the frontmatter and a `## Handoff` section (see `/pause-work` below).

`type` records `/start-work`'s classification (`routine`/`code-review`/`issue-work`/`feature`, = the 4a/4b/4c/4d buckets) and is not frozen — `/start-work` updates it in place if a session's character changes. It's what `/end-work`'s sandbox gate reads: only `issue-work`/`feature` sessions get the hands-on sandbox. Two optional lifecycle fields appear on those sessions: `lesson: done | deferred` (whether the optional teaching lesson was taught or postponed to the owed-learning queue — there is deliberately no third "declined" value, an absent field means not-offered-or-declined), and `sandbox: in-progress | fixed | not-reproducible | construction-failed` (the end-work drill's state — `in-progress` is transient, set only while a session is paused mid-sandbox; there is deliberately **no** `sandbox: deferred`, the sandbox is non-deferrable). Note the completion lifecycle: for an `issue-work`/`feature` session `/end-work` writes `ended_at` and flips `status: completed` only at a **final** step gated on a terminal `sandbox:` state — a session paused mid-sandbox stays `status: in-progress` and is closed later by `/resume-work`.

`db_baseline` is a **general** field on every session (not sandbox-scoped): `none` (no local DB, an ephemeral/auto-wiped DB, or a shared-DB skip — nothing to do) → `captured` (`/start-work` snapshotted the local dev DB before the first environment-setup change) → `restored` (`/end-work` reset the local DB back to that baseline at close). The mechanism for undoing local-DB changes made to exercise the work is **snapshot-and-restore**, not per-change tracking; the `## DB Baseline` section holds the snapshot record (target store(s), handle/path, capture command, machine). See the DB Baseline Protocol in the harness `/start-work` command and the restore step in `/end-work`.

`continues` is an optional field set **only on a follow-up session** — new work that picks up after a prior session already **completed** (PR merged, `/end-work` done). Rather than reopen the terminal note, `/start-work` opens a fresh session and points it back with `continues: <prior session_uid> [[path]]`. The link is **one-directional**: the prior completed note stays frozen (a one-time record), and context flows by the new session *reading* the prior note's `## Decisions`/`## Follow-ups`/`## Journal` plus the durable facts `/end-work` already persisted. This is distinct from a **paused** session (resumed via `/resume-work`) and from an **in-progress** session owned by another agent (left untouched). See `/start-work` step 2.

**Teach-before-gate is a standing invariant (TS-7), enforced per-session, not a clock.** From `/start-work` on, teaching precedes every comprehension gate and nothing is gated on material not presented in the current agent session; a new/materially-different issue surfacing mid-session forks to **work-now** (teach→gate, its fix-edit blocked until taught) or **park** (a Parking-Lot item file + flat INDEX row, no teaching), never a silent absorb. Enforcement rides the existing edit-gate — the fix needs an edit, the edit needs go-ahead, and go-ahead needs the teaching — so it holds across pause/resume and even `/end-work`'s post-merge sandbox. Because a session can teach+gate several issues, the `### Pedagogy` checkpoint is a **per-work-item list** (one `procedure`/`gate1`/`gate2`/`pos`/`status` row per item). `procedure:` records whether §Procedure ran when the gate was taught (compliance receipt — not permission to skip re-present on resume). Presentation of still-open gate material is re-done each session rather than durably recorded. Full doctrine: TS-7 in the installed Teaching Standard sidecar (`teaching-standard/Teaching-Standard.md` under the harness config directory).

`## Journal` is the running capture written *during* the session (see the Journal Protocol below); `## Log` stays the command-managed lifecycle log (the `paused`/`resumed`/closing lines the four commands append). They are different things and neither replaces the other.

Two id fields carry two different jobs, and it matters not to conflate them:

`session_uid` is the note's **stable identity** — a unique id generated once by `/start-work` at note creation (`uuidgen`) and **never changed thereafter**, not on pause, resume, or handoff. It uniquely names *this work session* no matter which agent (Claude Code, Cursor, etc.) is driving now or drove earlier, and it's generated the same way for every agent, so it's fully agent-agnostic. It exists precisely so a session has one durable handle across an arbitrary chain of agents, independent of the mutable `agent_id` below.

`agent_id` identifies the agent session that **currently owns** the note — whatever agent is running stamps its own session id (Claude Code → `CLAUDE_CODE_SESSION_ID`, Cursor → `CURSOR_CONVERSATION_ID`, any other → its own), so the matching isn't tied to one tool. `/start-work` stamps it; `/pause-work` and `/end-work` **match on it** so they act on the note *this* agent session started rather than whichever in-progress note is newest (which, with two agent sessions open on one repo, would otherwise let one close another's session). `/resume-work` **re-stamps** it with the resuming session's id, since resume runs in a new session — `session_uid` is left untouched. Notes predating these fields may have `agent_id` blank or carry the ownership id under the older `session_id` name (distinct from the new `session_uid` — the legacy `session_id` was an *agent* id, not a stable session identity); the commands fall back to that legacy field for matching, and otherwise list the in-progress notes and ask which to act on.

## Journal Protocol

The canonical spec for the `## Journal` section, so every agent that reads this file follows the
same rules rather than it being one command's private behavior. `/start-work` and `/resume-work`
both point here and instruct following it for the rest of their session.

**What it is.** A running, typed capture of what was learned and decided *while* it's fresh, so
`/end-work` (and any later lesson) works from a real record instead of an end-of-session
reconstruction that a long session's context loss degrades. It captures exactly what `git` cannot.

**Entry format:** `- <HH:mm> · <type> · <one to three sentences>`, where `type` is one of four:

| type | captures |
|---|---|
| `domain` | a fact about how the system/app/area works |
| `issue` | a problem observed or a root cause identified |
| `decision` | an approach chosen, and why |
| `dead-end` | an approach tried and rejected, and why it failed |

There is deliberately no `change` type: concrete edits live in `git` and end up in `## Files
Touched`. The types are best-effort tags, **not a strict partition**, because real events overlap. One
tie-break when an entry is both a system fact and a problem: tag `domain` if it stays true after
the fix ships, else `issue`; when genuinely dual, write two entries rather than force one tag.

**Trigger → tag** (the usual case): domain fact learned → `domain`; root cause identified →
`issue`; approach chosen → `decision`; approach abandoned → `dead-end`.

**Timestamp.** Take `HH:mm` from the `date` command (`date +%H:%M`), because this environment injects the
date only, no clock, so call `date` rather than guess; omit the timestamp rather than fabricate
one if it's unavailable. Entries are append-only, so their order in the section is their true
order regardless of timestamp precision.

**Which note.** Entries go to *this agent session's* note, the one matched by the `agent_id`
`/start-work` stamped, never "the newest in-progress note" (concurrent agent sessions on one repo would
otherwise cross-contaminate). Before appending, re-read the note fresh and apply the smallest
targeted patch to `## Journal`; never rewrite the note from a stale in-memory copy.

**Emptiness is valid.** A genuinely routine/mechanical session can produce zero entries; that's
expected, not a deficiency, and nothing nags about it.

**Known limits.** There is no hook, so journaling depends on the agent pausing to append at each
trigger event, and the whole system is agent-followed markdown with no code enforcement, so entry
format and tags are unvalidated by design and the discipline can decay under heavy context
pressure. Journaling narrows the loss window to whatever preceded the last entry; if journaling
never happened at all, it provides nothing, same as before. A session that ends without
`/end-work` still loses whatever wasn't journaled. Because `/end-work` writes Decisions/Follow-ups
partly from the Journal, any misclassification or omission there propagates into those sections.

## The four commands

- **`/start-work`** — opens a new session note (with an empty `## Journal`) and sets the Journal Protocol above in motion for the session. Before creating the note it runs a mandatory git-flow reset: switch to the base branch (`develop`, else `main`/`master`, else ask), pull it fresh, and cut a new branch off it named by the repo's `Agent/Patterns/<repo>/git-branch-and-commit-conventions.md`, leaving any uncommitted local changes in place to ride onto the new branch. If a paused session (`paused_at` set) exists for this repo, it points you at `/resume-work` rather than resuming inline. Also checks [[../Agent/README|Agent/Patterns]] and [[../Parking-Lot/README|Parking-Lot]] for this repo and surfaces anything relevant before diving in. For **every** session it then runs the **comprehension-gated tutorial** before any code — routine `4a`, issue-work `4c`, and feature `4d` get the full flow (present the situation 0→100 → hard-gate that understanding → present the intended solution → hard-gate it → a step-by-step tutorial the user drives, they write the code, the agent verifies), run *proportionately* for 4a (a mechanical change gets a small picture and a light gate, never a fabricated lesson); a code-review `4b` session runs the teaching-and-gate on the *diff* only — build the picture, gate comprehension, then the verdict, with no code-writing phase. The `just fix it` / `just the bottom line` escape hatch bypasses it per-instance for any type. It also captures a **local dev-DB baseline snapshot** before the first environment-setup DB change (`db_baseline: captured`), so `/end-work` can restore the local DB at close. Teaching always precedes each gate and re-arms on every newly-surfaced issue (**TS-7**, installed Teaching Standard sidecar); per-item gate state is checkpointed into the `### Pedagogy` list on pause, so a `/resume-work` doesn't lose or re-quiz them — it re-presents a still-open gate's material first.
- **`/pause-work`** — mid-session checkpoint, used when switching to a new agent session (e.g. approaching a context/token limit). Sets `paused_at` and writes a `## Handoff` section (what we were doing, current state, what's next, blockers, relevant files) into the session note itself. Does **not** close the note — the work is still logically open.
- **`/resume-work`** — run at the start of a fresh session. Finds the paused note, checks you're on the right branch, replays "what's next," clears `paused_at`, and continues the work. Carries the same Patterns/Parking-Lot pre-flight as `/start-work`.
- **`/end-work`** — closes out the session note: summary, decisions, files touched (from git), follow-ups, reading the `## Journal` as a source. Clears `paused_at` if the session was ended straight from a paused state. Then it persists the session's durable facts to their homes regardless of any lesson and without a per-note prompt: repo facts to [[../Agent/README|Agent/Patterns]], track concepts to `Concepts/`, off-track learnings to `Learning/`. Then, if the Journal has learnable content, it offers an optional comprehensive lesson (teaching only, it persists nothing) — three-way now: take it *now*, *later* (queued to `Work/Owed-Learning.md`, resurfaced only in `/new-session` and `/learn`), or *no*. For an `issue-work`/`feature` (4c/4d) session it additionally **blocks until the session's PR is merged** and then **always builds a standalone runnable, tested sandbox** under the external tree `~/DigitalBrain-Sandboxes/` — it reproduces the *original* state of affairs, and the user re-implements the fix in-session (no defer), checked against the *merged accepted diff* as the answer key. Because of that sandbox step, `/end-work` writes `ended_at`/`status: completed` only at a final step gated on a terminal `sandbox:` state; a session paused mid-sandbox stays `in-progress` and is finalized by `/resume-work` (see the sandbox/lifecycle steps in the harness `/end-work` command). On close it also **restores the local dev DB to the session's baseline snapshot** (`db_baseline: restored`) — a blunt reset reverting all local dev-DB state created to exercise the work; it runs for every session type that actually closes (including `routine`/`code-review` via the resume/finalize paths), but never on a paused-mid-sandbox exit or a merge-blocked early-exit, where the env DB must persist.

## Feeds into the Agent corner

This system is where things *happen*; [[../Agent/README|Agent/]] is where durable knowledge *accumulates* across many sessions. A session note is a one-time record ("here's what happened on 2026-07-02"); a pattern in `Agent/Patterns/<repo>/` is a standing fact ("this is still true, last checked 2026-07-02") that `/start-work` checks before every future session in that repo. Not every session produces one — most won't.

## Rules this system respects

- Never edits the actual repo — only reads `git status`/`log`/`diff` to describe what happened.
- Never adds an AI co-author trailer to commits, and never stages `.agent/` into a repo commit — see the global rules in the harness seeded `AGENT.md`.
