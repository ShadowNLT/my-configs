---
type: onboarding-meta
created: 2026-07-07
---

# How This Works

This is a self-run curriculum for going from beginner to expert on the **`apps/web3` checkout frontend** in `vivenu-core`, built and maintained by Claude across sessions. It lives entirely in this vault — Claude never edits the `vivenu-core` repo itself, only reads it for source material.

It is a sibling of [[../../Onboarding/Engine/00-How-This-Works|the checkout curriculum]], not a replacement for it — see [[../../Track-State|Track-State]] for how the two coexist and how a session picks which one applies. Everything in this file that isn't about `apps/web3` specifically is deliberately the same as the checkout curriculum's copy; see that file's own text if this one ever looks like it's drifted without a reason.

## Why it's built this way

Modeled on mastery-learning systems like MathAcademy, grounded in well-evidenced cognitive science (Bjork, Roediger, Dunlosky):

- **Prerequisite graph, not a linear list.** You can't understand the checkout flow before you understand the app's own architecture and state management. See [[../Curriculum-Map|Curriculum-Map]].
- **Retrieval practice over re-reading.** Each module accumulates a question bank in its own "Retrieval Practice" section — you get quizzed, not re-shown notes.
- **Spaced repetition, hand-rolled.** No Obsidian plugins are used (by design — plain vault only). Spacing is tracked in each module's frontmatter (`next_review`, `interval_days`, `ease`) and Claude manages it manually each session — there is no passive reminder inside Obsidian itself. If you don't open a session, nothing nudges you.
- **Interleaving.** Once past the first few modules, review questions mix older and newer modules rather than drilling one topic to exhaustion.
- **Desirable difficulty.** Quizzes are asked without hints first; hints only after a failed attempt, since struggle-before-help is what makes retrieval durable.

## Definition of "best" this curriculum targets

Same three axes as the checkout curriculum (your call, stated there): **codebase fluency**, **domain mastery**, and **system design ability**. For this track, codebase fluency skews toward `apps/web3` specifically (React Router v7, its state layer, its own gotchas), while domain mastery here means understanding the checkout *experience* (seating, payment UX, feature-flagged rollout) more than the backend entities the checkout curriculum already owns — see the Scope section below for exactly where the line is drawn.

## Cadence contract

Same daily, 15-30 minute session shape as the checkout curriculum. Since `web3` is the **active** track (per [[../../Track-State|Track-State]]), this is currently where that daily slot goes. If your actual cadence drifts, tell Claude — the intervals should be renegotiated, not silently ignored.

## Switching tracks

Say `/switch-track checkout` (or `web3`, to switch back) to change which curriculum a bare "start next module" or "quiz me" defaults to. This doesn't touch either curriculum's content or spaced-repetition state — it only changes routing. See [[../../Track-State|Track-State]] for the full mechanics, including the staleness guard that nudges you if the inactive track's reviews pile up past 7 days overdue.

## The hats

Same four tutoring personas as the checkout curriculum. See [[Hats]] for the personas and when each applies. Each module note names which hat applies.

## How to run a session

Just say what you want in a Claude Code session, e.g.:
- "Start W01" — Claude teaches the module, ends with a few retrieval questions.
- "Quiz me on W03" (or "quiz me, interleaved" once several modules are underway) — retrieval practice only, no re-teaching.
- "Where am I?" — Claude reads [[../Progress-Dashboard|Progress-Dashboard]] (and, per the staleness guard, glances at the checkout track's dashboard too) and tells you what's due.

`/new-session` and `/end-session` formalize this exactly as they do for the checkout curriculum — see the harness `/new-session` and `/end-session` commands, both now track-aware rather than checkout-specific. Plain language still works either way.

**End of every taught or quizzed session:** run `/end-session`. See that command directly for the authoritative procedure rather than a paraphrase here, for the same reason the checkout curriculum's doc gives — one copy of the steps, not two that can drift.

## Mid-module checkpoints

Identical mechanism to the checkout curriculum: if a session ends before a module is fully taught, Claude fills in that module's **Session Notes** section (last checkpoint, covered so far, still to cover, exact resume point) instead of an ad hoc recap. Say "checkpoint this module" to trigger it explicitly. Next session, say "continue W0X" — Claude reads Session Notes first and resumes from the stated point.

A cut-short session still owes a `Lessons/` note, written with whatever was actually covered and marked `status: in-progress` per [[Note-System]]. Once a module reaches `practicing` status, its Session Notes are cleared.

## Staying in sync with the codebase

Module notes point at real files in `apps/web3` (inside `vivenu-core`), which keeps moving — recent git history shows heavy, active development there (accessibility work, seating features, the works). Run `/sync-core` whenever `develop` has moved since the last check; it now runs against whichever track you invoke it for (or the active track, if you don't say). See [[Sync-Core]] for exactly what it fixes automatically versus what it proposes.

## Beyond the module chain: Lessons and Concepts

Same taxonomy as the checkout curriculum. Every taught session gets a dated note under `Lessons/`, and recurring entities (e.g. `SelectionState`, `OrderProvider`, the `vivenu-seatmap` service boundary) get their own atomic note under `Concepts/`. See [[Note-System]] for the linking rules — identical to the checkout curriculum's, restated here rather than cross-referenced only because Note-System.md's own text is short enough that a sibling copy costs less than a cross-vault jump every time you need it.

## Boundaries

- Claude reads `vivenu-core` read-only for source material; it never edits, commits, or runs anything destructive there as part of this curriculum.
- Notes point to files/classes by name rather than pasting large code blocks.
- Nothing here syncs anywhere outside this machine.
- This curriculum does not re-teach the checkout **backend** (`CheckoutManager`, `TransactionManager`, entity model) — that's the checkout curriculum's job (its M01-M03, M06-M07 specifically). Where a web3 module needs that backend context, it links to the relevant checkout module rather than re-explaining it. See the Scope section below.

## Scope

Covers **`apps/web3`** specifically: its architecture, state management, the concrete checkout user journey it renders, seating/payment/testing/accessibility as implemented there, and its own accumulated gotchas. It deliberately does **not** cover: the shared backend (owned by the checkout curriculum), `apps/web` (the legacy frontend, covered only as a contrast point in [[../Modules/W01-Local-Dev-Setup-And-The-Checkout-Routing-Trap|W01]]), or non-checkout parts of `apps/web3` if it has any (none identified as of the 2026-07-07 recon that grounded this curriculum — if that changes, `/sync-core` should surface it as new-material). See [[../Curriculum-Map|Curriculum-Map]] for the 11 modules. Other domains beyond checkout and web3 can get their own `Vivenu/Onboarding-<Domain>/` sibling later using this same pattern.
