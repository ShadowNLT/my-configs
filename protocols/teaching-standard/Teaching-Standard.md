---
type: teaching-meta
version: 2 — 2026-09-02
repo-canonical: true
---

# The Teaching Standard

The canonical doctrine for **how** any agent teaches, quizzes, presents code, or walks the user
through a change — corporate commands, personal commands, and curriculum sessions all pull from
**this file in the repo**. Each harness keeps an **installed copy** in its `teaching-standard`
sidecar (see `protocols/teaching-standard/README.md` for install — path is user-given at seed
time, never hardcoded in this repo). When repo and installed copy diverge, **this repo file wins**
until re-installed.

Seven quality rules (TS-1…TS-7) plus one mandatory **Teaching Procedure** (§Procedure) that
runs before any load-bearing explanation. The rules say *what good looks like*; the procedure
says *how to produce it* so agents cannot free-hand expert summaries and call it teaching.

---

## Philosophy — Math Academy style, grounded in the knowledge graph

This standard is modeled on mastery-learning systems (MathAcademy-style) and the cognitive-science
basics already encoded in the vault curricula (prerequisite graphs, retrieval practice, desirable
difficulty, spaced follow-up elsewhere):

| Principle | What it means in practice |
|---|---|
| **Prerequisite graph, not a lecture** | Never open with the conclusion. Decompose what the learner must hold, teach dependencies before dependents, and make the graph explicit for anything non-trivial. |
| **Derive, never assert** | Every load-bearing claim is built from something already established in this session or linked from prior vault coverage — not dropped as jargon the learner is expected to already know. |
| **Knowledge graph as external memory** | Before teaching, search the vault graph (`Concepts/`, track `Modules/`, freestanding `Learning/`, and `Curriculum-Map` prerequisites where relevant). Teach **only the delta**; link back instead of re-deriving what is already mastered. |
| **Retrieval over re-reading** | Comprehension is checked by having the learner **produce** understanding (restate, apply, answer why/how) — not by asking "does that make sense?" and moving on. |
| **Desirable difficulty** | Hints come **after** a miss, not before the first attempt. Struggle-then-scaffold is what makes retrieval durable. |
| **0→100 on the work's dependency chain** | For issue-work and feature sessions, the learner must reach full coverage of every concept the fix depends on — not a tour of the symptom. Scale depth to the real chain; don't pad unrelated context. |

**What this standard is not:** it does not own spaced-rep scheduling, Lesson-note persistence, or
Module Hat personas — those live in `/learn`, `/new-session`, `/end-session`, and the track
Engine docs. It *does* own the live teaching moment: decompose → reconcile → build → check.

---

## How it fires — read this first

These are in-the-moment reflexes, not a spec you read once. A command that only *pointed* here
would never re-open this file mid-quiz, so the rules would silently not fire. Therefore **each
teaching command inlines a compact trigger** at each firing site — a terse, named cue like
*"Teaching Standard: run §Procedure; TS-1 plain + derived; TS-2 cite path; TS-5 you write the
code"* — and this file holds the full rationale. The trigger is the reflex; this doc is the
reference.

**Load-bearing moments** (always run §Procedure — never free-hand):
- The **0→100 picture** (issue-work root cause, feature state-of-affairs)
- The **code-review picture** (4b: what the diff does and why, scaled — not the full 0→100 map)
- The **solution presentation** (intended approach before editing)
- A **reveal** after a failed gate round
- Any **multi-layer concept** the learner must hold to proceed
- An **`/end-work` sandbox README** (the picture before the fix)
- A **deferred owed lesson** rebuilt from session artifacts
- **Curriculum module teaching** (`/new-session` new-teach path)

**Quick clarifications** (TS-1 inline only — skip full §Procedure): a single-sentence answer to
a narrow question mid-flow, when the dependency chain is one link and nothing load-bearing
remains unstated.

When unsure whether a moment is load-bearing, **run §Procedure** — the default leans toward
procedure, not improvisation.

---

## §Procedure — mandatory teaching steps (load-bearing moments)

Run these steps **in order** before delivering a load-bearing explanation or running a gate on it.
This is the structural fix for "expert summary disguised as teaching."

### P1 — Terminal concept
One sentence: what must the learner understand *right now*? For a bug, the terminal concept is
usually the **mechanism of failure**, not the fix. For a feature, it is the **state of affairs
plus the gap** the ticket closes.

### P2 — Prerequisite chain (backward decomposition)
Working backward from P1 until you hit ideas the learner already holds (ordinary background or
vault notes you will link). List the chain explicitly — even if you only show the learner the
forward build, **you** must know the full chain. No skipped links.

Floor varies by context:
- **0→100 / curriculum depth:** floor is ordinary-adult understanding; link vault notes for
  anything above that rather than re-teaching mastered material.
- **JIT `/learn` depth:** floor is "already known to this user **or** not load-bearing for the
  immediate next action" — state the boundary out loud.

If the chain requires most of an unstarted Module, stop and route to `/new-session` instead of
ad hoc teaching the whole module.

### P3 — Knowledge-graph reconcile (read-only)
When this harness has a **configured knowledge vault root** (set at seed time — corporate work
harnesses usually have one; personal harnesses may not), search under that root, at minimum:
- `Concepts/*.md` across every onboarding track listed in that vault's track-state file
- `Modules/*.md` on those tracks
- `Learning/*.md` (freestanding JIT notes, if present)
- Relevant curriculum-map prerequisites when the topic sits on a track

All paths above are **relative to the configured vault root** — never assume a fixed location on
disk. Teaching commands resolve the root from the harness seed variables they were installed with.

When no knowledge vault is configured for this harness, skip search and treat P2 nodes above the
session floor as **Gap** — still no asserting what should have been linked.

For each node in P2's chain, classify:
- **Mastered** — a vault note covers it and the session doesn't need to re-derive → **link, don't
  re-teach**
- **Partial** — note exists but misses the load-bearing slice → teach **delta only**, then link
- **Gap** — no prior coverage → full build in P4
- **Stale** — a vault note exists but **live code contradicts it** → teach from the code, name the
  contradiction explicitly in the reconcile line, and queue a note correction in the session note's
  `## Follow-ups` (so `/end-work` can fix the vault note rather than leaving it to rot)

A configured directory that does not exist on disk (e.g. a track with no `Concepts/` folder) is a
**normal no-op**, not an error — skip it and continue.

**Deliverable before P4:** one explicit reconcile line naming each P2 node and its classification,
plus any links. Example: *"idempotency → mastered [[Concepts/idempotency]]; reducer dispatch order
→ gap; webhook retry semantics → partial (delta: double-delivery case)."* This line is mandatory —
teaching without it is a §Procedure skip.

### P4 — Knowledge map
Sketch the **small map** — concepts as nodes, dependencies as edges — for everything this
teaching moment depends on. Teach forward through the map in dependency order.

Scale by context:
- **0→100** (issue-work, feature, owed lesson, session lesson): full map on the work's dependency
  chain — every load-bearing concept appears as a node.
- **Proportionate** (routine 4a, JIT `/learn`, code-review 4b): only the nodes the moment actually
  needs — a one-link chain is one node, not a manufactured graph.

### P5 — Build forward (first-principles delivery)
Teach P4 in **forward order**, one link at a time:
- Each new idea uses only common knowledge, vault-linked mastery, or concepts established
  **earlier in this same explanation**
- Make callbacks explicit: "Now that X holds, Y is…"
- Cite real locations (TS-2) as you touch code or vault notes
- Analogies only when they clarify a real relationship — flag where they break down

This step **is** the explain-first-principles procedure. For load-bearing moments, read
`{{AGENT_COMMANDS_DIR}}/explain-first-principles.md` and **execute its steps inline** — you
cannot invoke a slash command; reading the file and executing its steps is the only path. When
running as load-bearing 0→100, the P2 prerequisite chain and forward build must appear in the
delivered output (see that file's P5-mode output rule). A prose summary with no visible chain is a
§Procedure failure, not TS-1 compliance.

**P5 completion test (before gating or treating P5 done):** the delivered explanation must
include (a) the mandatory P3 reconcile line naming every P2 node, and (b) each P2 node built
forward in dependency order — each derived from common knowledge, vault-linked mastery, or a node
already established earlier in the same explanation, not dropped as asserted jargon. If any node
is missing from the delivery or appears only as an assertion, P5 is not complete.

Modality within P5: **worked-example-first** for procedural chains; **analogy-build** for
conceptual ones — always after the prerequisite link is established, never instead of it.

### P6 — Plain render (clarity pass)
When the explanation is dense, jargon-heavy, or multi-layer, read
`{{AGENT_COMMANDS_DIR}}/layman-terms.md` and execute its clarity pass on the P5 output — you
cannot invoke a slash command. It is a **clarity rewrite**, not a substitute for P2–P5 — it never
creates content that wasn't derived in P5. If P5 is already plain, skip P6.

**Self-check before gating or editing:** any term in the delivered explanation that appears before
it was defined in P5 or linked from vault? If yes, go back — do not gate on asserted jargon.

---

## The rules

### TS-1 — Plain, first-principles, nothing load-bearing asserted
Every explanation meets the **one-read bar**: understandable on a single read, and every claim the
learner needs is **derived**, not asserted. §Procedure P2–P5 is how TS-1 is enforced on
load-bearing moments; quick clarifications meet the same bar inline.

- *bad (asserted):* "It fails because the reducer isn't idempotent."
- *good (derived):* "Running this twice adds the charge twice — the function isn't safe to repeat.
  A function safe to repeat is called *idempotent*; this one isn't, and that's the bug."

### TS-2 — Cite the location of every file or snippet
A **snippet** = a fenced or multi-token quoted code block. A bare symbol in prose (`handleAuth`)
is exempt. Whenever you name a file or show a snippet:
- **repo code** → `<repo>/<path>:line`
- **vault note** → vault-relative path (e.g. `Concepts/idempotency.md`)
- **external** → URL

Never a bare filename; never an uncited block.

### TS-3 — Lead every walkthrough step with the why-here
*(Fires only where the learner edits real code — see Applicability.)* Each step **opens with why
this file and why this edit here**, before mechanics — depth proportionate to how non-obvious the
choice is. The learner never applies an edit without knowing why it goes there.

### TS-4 — Hints are plain, never cryptic
A hint **names the specific thing** missing and nudges plainly (TS-1). Socratic questions are
fine **only if they plainly state what they're probing**. Composes with **no-hints-first** timing
(hints only after a miss); TS-4 governs hint *content*.

### TS-5 — The learner writes the production code
*(Fires only where the learner edits real code — see Applicability.)* The user writes the fix /
feature / production change. You may write tests, fixtures, and scaffolding — not the substantive
logic routed through a helper. **When unsure, ask.** You write production code only on explicit
request — `"just fix it"` / `"just build it"` counts.

The **`/end-work` sandbox** is stricter: the user always writes the fix; no escape hatch.

### TS-6 — The gate / reveal ladder
*(Work-session comprehension gates.)*
- **Pass:** restate in own words **and** correctly answer a why/how follow-up — gist with correct
  reasoning, not verbatim recall.
- **Failed round:** one ask → wrong / incomplete / absent answer.
- **After 4–5 failed rounds:** reveal + explain (run §Procedure on the reveal), then **re-quiz
  the revealed material** — never a free pass.
- **Terminal states: pass or pause.** Never advance without pass; never silent skip. Fatigue after
  reveal → offer `/pause-work`.

**Ungraded** work-tutorial ladder. `new-session` curriculum quizzes use **graded mastery** per
Module Hat — TS-6 does not govern those.

### TS-7 — Teach before you gate, every session
Teaching **precedes** every comprehension gate. **No gate runs on material not presented in the
current agent session.** Picture → Gate 1; solution → Gate 2. Resumed sessions **re-present**
still-open gate material before running the gate (presentation is not durably checkpointed).
Passed gates are not re-run.

**Enforcement rides the edit-gate:** fixing an issue whose §Procedure + presentation has not run
this session is blocked — the edit requires go-ahead, and go-ahead requires teach-first.

**Scope:** wherever a gate exists — `start-work` Phases 1–3, resumed gates, `/end-work` sandbox —
not "until PR merges."

**New issue mid-session:** stop; offer **work now** (→ its own §Procedure + gates) or **park**
(→ create `Parking-Lot/<repo>/<slug>.md` and add a row to the flat `Parking-Lot/INDEX.md`; no
teaching). Never fold a materially-different issue into current work ungated. Per-item `"just fix
it"` bypasses teaching for that item only.

**`procedure:` on Pedagogy rows (compliance receipt, not presentation):** when a work-session gate
passes under the new schema, record `procedure: complete` (or `partial(…)` / `none` if §Procedure
was skipped or defective). A `none` or `partial` value **blocks recording the gate as passed**.
Absent `procedure:` on legacy rows = `unrecorded` — do not invalidate an existing `gate1:
passed`. `procedure: complete` does **not** satisfy TS-7's re-present requirement on resume — it
only records that §Procedure ran when the gate was first taught this session.

---

## Applicability — when TS-3 and TS-5 fire

TS-1, TS-2, TS-4, and §Procedure apply to **all** teaching. TS-6 applies to work-session
comprehension gates. TS-7 governs ordering and enforcement of those gates plus the `/end-work`
sandbox.

**TS-3 and TS-5 fire only where the learner edits real, source-controlled code** — `start-work`
Phase 4 (all editing sessions: 4a/4c/4d, proportionate for 4a), resumed Phase 4, `/learn` confirm-
by-application on a real file, `/end-work` sandbox. They do **not** fire in pure study
(`new-session`), read-only explanation, code-review (4b), or `/learn` on reasoning/pseudo-code
only. Say so in one line when they flip on.

---

## Coverage matrix — which rules fire in which command

| Command | §Procedure | TS-1 | TS-2 | TS-3 | TS-4 | TS-5 | TS-6 | TS-7 |
|---|---|---|---|---|---|---|---|---|
| `start-work` | ✓ (0→100, solution, reveals) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| `end-work` | ✓ (lesson, sandbox README, reveals) | ✓ | ✓ | ✓† | ✓ | ✓‡ | ✓ | ✓ |
| `resume-work` | ✓ (re-present) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| `learn` | ✓ (scaled to JIT depth) | ✓ | ✓ | when editing | ✓ | when editing | —§ | —§ |
| `new-session` | ✓ (module teaching) | ✓ | ✓ | N/A | ✓ | N/A | —¶ | N/A |
| `explain-first-principles` | ✓ (= P2+P5) | ✓ | ✓ | N/A | ✓ | N/A | N/A | N/A |
| `layman-terms` | —‖ | —‖ | — | — | — | — | — | — |
| `concept-viz` | optional (after P5) | ✓ | ✓ | N/A | N/A | N/A | N/A | N/A |
| `pause-work` | — | — | — | — | — | — | checkpoint only | checkpoint only |

† lesson walkthrough only, not sandbox brief  ‡ sandbox = stricter, no escape
§ `/learn` Step 5 confirm-by-application is its own gate (apply until it works), not TS-6's ladder
¶ graded mastery quiz per Module Hat, not TS-6
‖ clarity pass only (P6); not a teaching command

**Excluded** (no live teaching): `end-session` (records only), `dream`, `switch-track`,
`sync-core`, `code-pi`, `ponytail`.

---

## Install (not in any knowledge vault)

This standard lives in the **harness config sidecar**, not inside a work/knowledge vault. At seed
time the user names their harness `CONFIG_DIR`; the installed copy goes to
`$CONFIG_DIR/teaching-standard/Teaching-Standard.md`. See `protocols/teaching-standard/README.md`.

Teaching commands reference the **installed sidecar path** at runtime (via harness seed variables)
or this **repo path** during development. Re-install after any edit here; never treat the installed
copy as source of truth.

---

## Compact triggers (copy into commands)

**Load-bearing teach:**
`Teaching Standard §Procedure + P5 completion test + TS-1 derived + TS-2 cite path + TS-4 plain hints`

**Gate:**
`Teaching Standard TS-6 ladder + TS-7 teach-before-gate + TS-4 plain hints`

**Phase 4 / sandbox edit:**
`Teaching Standard TS-3 why-here + TS-5 you write production code + TS-2 cite path`

**JIT learn:**
`Teaching Standard §Procedure (JIT floor) + TS-1 + TS-2 + TS-4; confirm-by-application gate`
