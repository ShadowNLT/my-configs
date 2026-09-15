---
name: converge
description: >-
  Fan out 2 independent agents to propose how to do a task; loop until their
  plans match in substance and artifacts (a third independent agent cannot find
  a difference between the two approaches), or stop after n rounds (default 4)
  and report. Reports the agreed plan only — never executes it. Use when a
  "simple" task should still get a best-how plan before anyone acts.
  Trigger on: "/converge", "converge on how", "fan out two plans until they
  agree", "two agents propose then converge", "agree on the approach first".
---

# converge

You are the **orchestrator**: you seal the brief, spawn proposers and a differ,
decide converge / continue / stop. You do **not** execute the plan.

Fan out **2 independent agents**. Each proposes **how** they would do the
task. If they do not converge, repeat until they do. If you have looped more
than `n` times, stop and report to the user.

**Lane:** this owns **task → agreed how-plan (report only)**. Competing fix
proposals under adversarial pressure → `/proof-duel`. Plan/doc hardening →
`/adversarial-review`. Minimality of an already-chosen plan → `/ponytail`.
Blast radius → `/code-pi`.

**Layman-terms rule (every user decision point):** stop-and-ask moments go
through the `layman-terms` skill when available; otherwise apply its standard:
one-read plain language, jargon defined or replaced, no substance dropped.

---

## 1. Infer target and parameters

There is no argument string to parse. Infer from the conversation:

| Parameter | Default | Meaning |
|---|---|---|
| `n` | `4` | Max fan-out rounds (integer ≥ 1). User may state an override. |
| task | required | What to plan. Prefer the most recent substantive task the user is deciding how to do. **State which you picked.** Ambiguity → ask, don't guess. |

Reject invalid `n` rather than guessing/clamping. Cap `n` at 8; if the user
wants more, ask them to confirm the spend before starting.

State in one line: `n=<n> task=<one-line restatement>` then proceed.

---

## 2. Seal the brief (before any proposer runs)

Write a **Task Brief** once. Every proposer and the differ get this exact
text — no later enrichment for one agent only.

```markdown
## Task Brief
- **Task:** <one crisp statement>
- **Constraints:** <hard limits, non-negotiables>
- **Out of scope:** <explicit>
- **Success looks like:** <checkable outcomes for the *plan*, not the execution>
- **Context refs:** <paths / facts every proposer may use — same list for all>
- **Required artifacts:** <what each proposer must emit — see §3>
```

Do not start round 1 until the brief is sealed. If the task is still fuzzy,
ask — do not invent constraints.

---

## 3. Required plan artifact (exact shape)

Every proposer emits **only** this shape (no model names, no round diary, no
cross-references to the other proposer):

```markdown
## Plan
### Approach
<how — ordered steps, enough to act on without guessing>

### Artifacts
- <concrete outputs: files, commands, APIs, UI surfaces, data shapes — paths and names when known>

### Order
1. <step>
2. <…>

### Non-goals
- <explicit exclusions>

### Assumptions
- <load-bearing assumptions>
```

Orchestrator validates shape before comparison. Malformed → one re-request to
that proposer; still bad → treat that round as non-converged and advance (do
not repair their substance yourself).

---

## 4. Converge test (definition)

**Converged** means the two plans match in **substance** and have
**near-identical artifacts**, such that an independent agent cannot find a
difference between the two approaches.

Operational check (required when the two plans look aligned):

1. Spawn a **third independent agent** (the **differ**) that sees **only**: the
   Task Brief, Plan A, and Plan B — sealed from the proposers' identities and
   from prior-round chatter.
2. Differ mandate: list every difference that would change *how* someone
   executes the plan (steps, order, artifacts touched, non-goals, load-bearing
   assumptions). Ignore pure wording / formatting / synonymy.
3. If the differ returns **no substantive differences** → **converged**.
4. If the differ returns **any** substantive difference → **not converged**.

The orchestrator does **not** soft-pass "close enough." The differ's empty
diff is the gate. If the Agent / Task tool is unavailable, the orchestrator
plays the differ role sequentially and labels `independence: reduced`.

---

## 5. Round loop (max `n`)

For round `r = 1 .. n`:

### 5.1 Fan out two proposers

Spawn **2 independent proposers in parallel** (unless the harness cannot; then
sequential with `independence: reduced`). Each receives **only** the sealed
Task Brief (and, from round 2 on, the **Diff Themes** block below — never the
other proposer's full plan).

**Model assignment (when the harness supports choosing models):** prefer two
different model families for the proposers when a pool is available; log
`diversity: degraded` if not. The differ should be a third model when
available; otherwise log `differ: pool-exhausted, independence reduced`.

Label proposers only in orchestrator-private notes. Proposers never see each
other's drafts.

### 5.2 Collect and (if needed) shape-fix

Validate both artifacts per §3.

### 5.3 Differ

Run the converge test (§4).

### 5.4 Outcome

- **Converged** → go to §6 (success). Stop the loop.
- **Not converged** and `r < n` → build a **Diff Themes** block from the
  differ's findings (themes only — no full rival plan). On the next round,
  append that block to the sealed brief copy each proposer gets:

  ```markdown
  ## Diff Themes (from prior round — resolve these; do not copy a rival plan)
  - <theme>
  ```

  Then start round `r+1` with fresh proposers (do not resume contaminated
  proposers; new sealed runs).
- **Not converged** and `r = n` → go to §7 (exhausted).

---

## 6. Success — report only

Emit the agreed plan once (use either proposer's artifact if the differ found
no differences; if tiny wording differs, pick one and note `wording: normalized
from A|B`).

```markdown
## Converged plan
- **Rounds used:** <r> of <n>
- **Differ:** no substantive differences

<the Plan artifact>
```

**Do not execute.** Do not start implementing, editing files, or running the
steps unless the user explicitly asks in a later message. End the turn after
the report.

---

## 7. Exhausted — stop and report

After `n` rounds without converge:

```markdown
## Converge failed
- **Rounds used:** <n> of <n>
- **Still divergent:** <bullet list of differ themes from the last round>

### Plan A (latest)
<full artifact>

### Plan B (latest)
<full artifact>

### Differ findings (latest)
<numbered differences>
```

Do **not** pick a winner, merge the plans, or execute. Hand the divergence to
the user and stop.

---

## 8. Anti-patterns

- Executing the plan after converge (report only).
- Declaring converge because the orchestrator "likes" both plans without a
  differ pass.
- Showing one proposer's full plan to the other.
- Silently raising `n` or skipping a round to save tokens.
- Using `/proof-duel` mechanics (writer/hater/judge) inside this protocol —
  different lane.
