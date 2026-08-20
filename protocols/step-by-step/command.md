---
description: Walk the user through achieving a goal ONE step at a time, with a checkpoint after each step — never advance until the current step's result is explicitly confirmed
argument-hint: [the goal to walk toward, or leave blank to infer]
---

# step-by-step

Goal: $ARGUMENTS — or, if empty, inferred from the conversation. If it's unclear, ask targeted
questions before drafting the plan.

Guide the user to a goal **one step at a time**. The rule that defines this
protocol: **never advance to the next step until the user has explicitly confirmed
the current step's result.** No batching, no running ahead.

This is a deliberately careful walkthrough. If the user would rather move
faster, they can ask to **group obviously-trivial consecutive steps** under a
single checkpoint — offer that only when steps are low-risk and reversible;
otherwise keep one step per checkpoint.

## 0. Durable state (do this — the protocol breaks without it)
The current step, the plan, and the retry counters must survive a context
compaction. Keep them in a state file in **this session's scratchpad
directory** (the path given in the environment/system prompt — do not hardcode
one; it is session-specific and keeps the user's repos clean):

    <session-scratchpad>/step-by-step-<slug>.md   (<slug> from the goal)

It holds: the goal + done-condition, the ordered plan, which steps are `DONE`,
the current step number, and per-step retry/re-plan counts. **Re-read it at the
start of every turn** to recover position; **update it after every checkpoint
and every re-plan.** Before performing a step, check it isn't already marked
`DONE` (guards against re-running a side-effecting step after a retry or
compaction).

The scratchpad is session-scoped, so it survives compaction within a session
but **not** a brand-new session. That's the intended trade-off (nothing written
into the user's repos); if a walkthrough must resume in a later session, say so
and keep the plan in the conversation or a user-chosen file instead.

## 1. Understand the goal
Infer the goal from the argument and the conversation. If it is unclear,
ambiguous, or underspecified, ask targeted questions until you can state a
**crisp goal and its done-condition** — the concrete, checkable condition(s)
that mean "achieved" (a checklist if it has several parts). Confirm it with the
user, then write it to the state file.

**Pre-check:** if the done-condition already holds, say so and stop — do not
manufacture steps for an already-met goal.

## 2. Draft the plan, then get it approved
Produce an ordered list from here to the goal:
- Keep steps **small and checkable**. The *near* steps should be concrete; *far*
  steps may be coarse and get sharpened as you approach them (the plan is a
  living list, not a contract).
- Each step notes **who acts** — the agent, the user, or a composite
  ("the agent does X, then you do Y").
- Show the **full arc** with a marker on the current step (`Step 1 of N`).
- **Then wait for approval.** Do not start step 1 until the user approves or
  adjusts the plan. Write the approved plan to the state file.

For a single-step goal, skip the ceremony — just do §3 once.

## 3. Execute exactly one step
For the current step only, in one turn:
1. State: `Step N of M`, what the step does, who acts, and the **expected
   result phrased as something the user can directly observe** (e.g. "the
   terminal prints `OK`", "the file `x.py` now exists") — not an expert
   judgment the user can't make. State it **before** acting.
2. **If the step is irreversible** (delete, deploy, send, overwrite, pay):
   say so explicitly, note it can't be retried, and get a clear go-ahead
   *before* acting.
3. Perform it (if it's the agent's) or give the user minimal, exact instructions
   (if it's theirs).
4. Show the **actual result**. Where the agent can verify it itself (exit code,
   file exists, test passes), do so and report the verdict — don't make the
   user adjudicate what the agent already knows. If the step has **no observable
   outcome yet**, say so honestly and note which later step will confirm it.
5. **Stop.** Don't read ahead, prepare, or hint at step N+1. (The no-look-ahead
   rule applies to execution turns; showing the whole arc in §2 is fine.)

## 4. Checkpoint — confirm before advancing
- **Only an explicit affirmative advances.** A question, "sort of", a new
  result, a tangent, or silence is **NOT** a confirmation — treat it as
  unconfirmed: address it, then re-ask. Never read a non-answer as "yes."
- **Confirmed match** → mark the step `DONE` in the state file, advance to §3.
- **Mismatch** → do **not** advance. Diagnose, then **retry** the step (same
  approach, fixed) up to **2 retries**; if still failing, do **one re-plan**
  (§5). Track these counts in the state file.

## 5. Re-plan when reality diverges
If a step's outcome shows the plan is wrong, revise the **remaining** steps
(never the completed prefix), show the updated arc, and say the count changed
(`re-planned: now M steps`). The completed-step numbers stay frozen; `M` is the
current total. A re-plan must make progress — if two successive re-plans don't
reduce the remaining work toward the done-condition, treat the step as stuck
(§6). The user may also steer: **go back to a step, skip one, or insert one** —
honor it and renumber.

## 6. Termination
Stop when any of these holds:
- **Done-condition met** (final step confirmed) → summarize what was achieved
  against §1's done-condition; delete the state file, or if follow-ups remain,
  leave it and say where it is.
- **User ends it** — via `/step-by-step stop`, or a clear standalone "stop" /
  "we're done". If a stop-like phrase is **ambiguous or embedded** in other
  content ("don't stop the server"), ask "end the walkthrough?" rather than
  assuming. On end: summarize which step we reached and what remains.
- **Retry budget exhausted** — a step still failing after 2 retries and a
  re-plan is **stuck**: stop, report the blocker plainly, hand control back.
  Don't thrash.

## Discipline (the whole point)
- **One step per turn.** Never batch (unless the grouping rule above was agreed)
  or run ahead of the checkpoint.
- **Never advance past an unconfirmed or mismatched checkpoint.**
- **Show `Step N of M` every turn**, recovered from the state file, so position
  is clear across a long conversation.
- If the user invokes `/step-by-step` while one is already in progress, ask
  whether to replace it or resume the existing plan.
- This is judgment, not rigid automation — when the next step or its expected
  outcome is genuinely unclear, ask rather than guess.